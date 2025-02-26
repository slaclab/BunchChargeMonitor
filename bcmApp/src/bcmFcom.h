// Number of BCM parameters that must be sent through FCOM (TMIT and STATUS)
#define NUM_BCM_PARAM 2

struct tBcmStats { 

    int fcomTransmitted;
    int fcomTxError;
    int fcomInvalidAtcaIp;
    int fcomInvalidAtcaIpPort;
    int cannotCreateSocket;
    int sendToFailed;

    epicsTime diff;

};

struct tBcmPacket {
    uint32_t header;
    uint32_t timel;
    uint32_t timeu;
    uint32_t status;
    uint32_t tmitA;
    uint32_t unused[2];
}

class BcmFcom {

    private:
        struct tBcmStats bcmStats;
        struct sockaddr_in atcaIpToSendTMIT;

        // Blob to be sent to FCOM
        FcomBlob bcmTxBlob;
        //Data inside blob that is sent to FCOM
        
        static BcmFcom* instance;
        BcmFcom();
        BcmFcom(const BcmFcom&);

        void processBlob(FcomBlobRef bcmBlob);
    
    public:
        
        ~BlenFcom();
        static BcmFcom* getInstance();

        void registerTmitId(std::string pvName);
        
        int fireFcomTask();

        void fcomTask();
        void sendData(bsaData_t* bsaData);
        struct tBcmStats getStats();
}
