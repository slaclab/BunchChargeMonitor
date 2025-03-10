

// More than 8.3 ms means we effectively lost the TMIT arrival
volatile unsigned bcmFcomTimeoutsMs = 9;

// Signleton design pattern: initialize class instance pointer to null
BcmFcom* BcmFcom::instance = 0;

BcmFcom* BlenFcom::getInstance() {
    if (instance == 0) {
        instance = new BcmFcom();
    }

    return instance;
}

static void C_fcomTask(void *p) {
    BcmFcom* pBcmFcom = BcmFcom::getInstance();
    pBcmFcom->fcomTask();
}

BcmFcom::BcmFcom() {

}

// Get fcom ID related to TORO PV
void BcmFcom::registerToroId(std::string pvName) {
    toroId = fcomLCLSPV2FcomID(pvName.c_str());
}

// Get fcom ID related to bunch length PV
void BcmFcom::registerArawId(std::string pvName) {
    aRawId = fcomLCLSPV2FcomID(pvName.c_str());
}

// Receives IP address and port in the format <IP>:<port>
void BcmFcom::registerAtcaIpToSendTMIT(std::string ipColonPort) {
    char* auxStr;

    char ipColonPort_C[INET_ADDRSTRLEN + 6];

    strncpy(ipColonPort_C, ipColonPort.c_str(), sizeof(ipColonPort_C));

    auxStr = strtok(ipColonPort_C, ":");

    memset((char *)&atcaIpToSendTMIT, 0, sizeof(atcaIpToSendTMIT));

    if (inet_pton(AF_INET, auxStr, &(atcaIpToSendTMIT.sin_addr)) <= 0) {
        errlogPrintf("IP address format invalid: %s\n", auxStr);
        blenStats.fcomInvalidAtcaIp = 1;
    }

    auxStr = strtok(NULL, ":");

    if (auxStr != NULL) {
        atcaIpToSendTMIT.sin_port = htons(atio(auxStr));
    }
    else {
        errlogPrintf("Port number invalid!\n");
        blenStats.fcomInvalidAtcaIpPort = 1;
    }
    
    socketFd = socket(PF_INET, SOCK_DGRAM, 0);
    blenStats.cannotCreateSocket(socketFd < 0);   
}

int BlenFcom::fireFcomTask() {
    int rc = 0;
    int st = 0;

    // subscribe to TMIT value
    rc = fcomSubscribe(tmitId, FCOM_SYNC_GET);
    if (rc) {
        errlogPrintf("ERROR: %s\n", fcomStrerror(st));
        return -1;
    }

    epicsThreadCreate("bcmFcomTask", epicsThreadPriorityHigh+3,
                      epicsThreadGetStackSize(epicsThreadStackMedium), 
                      (EPICSTHREADFUNC) C_fcomTask, NULL);
    return 0;
}

void BcmFcom:processBlob(FcomBlobRef toroBlob) {

    if (blenStats.fcomInvalidAtcaIp != 0) ||
       (blenStats.fcomInvalidAtcaIpPort != 0) {
        return;
        }

    if (blenStats.cannotCreateSocket) {
        socketFd = socket(PF_INET, SOCK_DGRAM, 0);
        blenStats.cannotCreateSocket = (socketFd < 0);
    }

    if (blenStats.cannotCreateSocket) {
        blenStats.sendToFailed = 1;
        return;
    }
    
    struct tTmitPacket tmitPack;
    // Header is always zero
    tmitPack.header = 0;
    
    tmitPack.timel = bpmBlob->hdr.tsLo;
    tmitPack.timeu = bpmBlob->hdr.tsHi;
}

void BlenFcom::sendData(bsaData_t* bsaData) {

    FcomGroup fcomGroup;
    int st;

    st = fcomAllocGroup(FCOM_ID_ANY, &fcomGroup);

    if (st) {
        blenStats.fcomTxError++;
        return;
    }

    // Fill array with bcm data
    blenTxBlob.fc_flt = blenTxData;
    bcmTxBlob.fcbl_bcm_tmit = static_cast<float>(bsaData->tmit);

    bcmTxBlob.fc_tsHi = bsaData->timeStamp.secPastEpoch;
    bcmTxBlob.fc_tsLo = bsaData->timeStamp.nsec;

    bcmTxBlob.fc_vers = FCOM_PROTO_VERSION;
    bcmTxBlob.fc_idnt = tmitId;
    bcmTxBlob.fc_type = FCOM_EL_FLOAT;
    bcmTxBlob.fc_nelm = 1;

    // TODO: Need to define invalid tmits:
    bcmTxBlob.fc_stat = FC_STAT_BLEN_OK;


    st = fcomAddGroup(fcomGroup, &blenTxBlob);
    if (st) {
        bcmStats.fcomTxError++;
        return;
    }

    // Send group to multicast network:
    st = fcomPutGroup(fcomGroup);
    if (st) {
        bcmStats.fcomTxError++;
        return;
    }


    blenStats.fcomTransmitted++;
    blenStats.lastTmitSent = bcmTxBlob.fcbl_bcm_tmit;

}
