

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
}
