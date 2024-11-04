#ifndef __IDE_H
#define __IDE_H
#include "mytypes.h"


typedef struct _IDENTIFY_DEVICE_DATA {
  struct {
    word Reserved1  :1;
    word Retired3  :1;
    word ResponseIncomplete  :1;
    word Retired2  :3;
    word FixedDevice  :1;
    word RemovableMedia  :1;
    word Retired1  :7;
    word DeviceType  :1;
  } GeneralConfiguration;
  word NumCylinders;              // use it
  word ReservedWord2;
  word NumHeads;                  // use it
  word Retired1[2];
  word NumSectorsPerTrack;        // use it
  word VendorUnique1[3];
  byte  SerialNumber[20];
  word Retired2[2];
  word Obsolete1;
  byte  FirmwareRevision[8];
  byte  ModelNumber[40];
  byte  MaximumBlockTransfer;
  byte  VendorUnique2;
  word ReservedWord48;
  struct {
    byte  ReservedByte49;
    byte  DmaSupported  :1;
    byte  LbaSupported  :1;        // use it
    byte  IordyDisable  :1;
    byte  IordySupported  :1;
    byte  Reserved1  :1;
    byte  StandybyTimerSupport  :1;
    byte  Reserved2  :2;
    word ReservedWord50;
  } Capabilities;
  word ObsoleteWords51[2];
  word TranslationFieldsValid  :3;
  word Reserved3  :13;
  word NumberOfCurrentCylinders;     // check it
  word NumberOfCurrentHeads;         // check it
  word CurrentSectorsPerTrack;       // check it
  dword  CurrentSectorCapacity;      // check it
  byte  CurrentMultiSectorSetting;
  byte  MultiSectorSettingValid  :1;
  byte  ReservedByte59  :7;
  dword  UserAddressableSectors;       // use it -- 28 bit LBA max
  word ObsoleteWord62;
  word MultiWordDMASupport  :8;
  word MultiWordDMAActive  :8;
  word AdvancedPIOModes  :8;
  word ReservedByte64  :8;
  word MinimumMWXferCycleTime;
  word RecommendedMWXferCycleTime;
  word MinimumPIOCycleTime;
  word MinimumPIOCycleTimeIORDY;
  word ReservedWords69[6];
  word QueueDepth  :5;
  word ReservedWord75  :11;
  word ReservedWords76[4];
  word MajorRevision;
  word MinorRevision;
  struct {
    word SmartCommands  :1;
    word SecurityMode  :1;
    word RemovableMediaFeature  :1;
    word PowerManagement  :1;
    word Reserved1  :1;
    word WriteCache  :1;
    word LookAhead  :1;
    word ReleaseInterrupt  :1;
    word ServiceInterrupt  :1;
    word DeviceReset  :1;
    word HostProtectedArea  :1;
    word Obsolete1  :1;
    word WriteBuffer  :1;
    word ReadBuffer  :1;
    word Nop  :1;
    word Obsolete2  :1;
    word DownloadMicrocode  :1;
    word DmaQueued  :1;
    word Cfa  :1;
    word AdvancedPm  :1;
    word Msn  :1;
    word PowerUpInStandby  :1;
    word ManualPowerUp  :1;
    word Reserved2  :1;
    word SetMax  :1;
    word Acoustics  :1;
    word BigLba  :1;
    word DeviceConfigOverlay  :1;
    word FlushCache  :1;
    word FlushCacheExt  :1;
    word Resrved3  :2;
    word SmartErrorLog  :1;
    word SmartSelfTest  :1;
    word MediaSerialNumber  :1;
    word MediaCardPassThrough  :1;
    word StreamingFeature  :1;
    word GpLogging  :1;
    word WriteFua  :1;
    word WriteQueuedFua  :1;
    word WWN64Bit  :1;
    word URGReadStream  :1;
    word URGWriteStream  :1;
    word ReservedForTechReport  :2;
    word IdleWithUnloadFeature  :1;
    word Reserved4  :2;
  } CommandSetSupport;
  struct {
    word SmartCommands  :1;
    word SecurityMode  :1;
    word RemovableMediaFeature  :1;
    word PowerManagement  :1;
    word Reserved1  :1;
    word WriteCache  :1;
    word LookAhead  :1;
    word ReleaseInterrupt  :1;
    word ServiceInterrupt  :1;
    word DeviceReset  :1;
    word HostProtectedArea  :1;
    word Obsolete1  :1;
    word WriteBuffer  :1;
    word ReadBuffer  :1;
    word Nop  :1;
    word Obsolete2  :1;
    word DownloadMicrocode  :1;
    word DmaQueued  :1;
    word Cfa  :1;
    word AdvancedPm  :1;
    word Msn  :1;
    word PowerUpInStandby  :1;
    word ManualPowerUp  :1;
    word Reserved2  :1;
    word SetMax  :1;
    word Acoustics  :1;
    word BigLba  :1;
    word DeviceConfigOverlay  :1;
    word FlushCache  :1;
    word FlushCacheExt  :1;
    word Resrved3  :2;
    word SmartErrorLog  :1;
    word SmartSelfTest  :1;
    word MediaSerialNumber  :1;
    word MediaCardPassThrough  :1;
    word StreamingFeature  :1;
    word GpLogging  :1;
    word WriteFua  :1;
    word WriteQueuedFua  :1;
    word WWN64Bit  :1;
    word URGReadStream  :1;
    word URGWriteStream  :1;
    word ReservedForTechReport  :2;
    word IdleWithUnloadFeature  :1;
    word Reserved4  :2;
  } CommandSetActive;
  word UltraDMASupport  :8;
  word UltraDMAActive  :8;
  word ReservedWord89[4];
  word HardwareResetResult;
  word CurrentAcousticValue  :8;
  word RecommendedAcousticValue  :8;
  word ReservedWord95[5];
  dword  Max48BitLBA[2];               // MBZ -- check it
  word StreamingTransferTime;
  word ReservedWord105;
  struct {
    word LogicalSectorsPerPhysicalSector  :4;
    word Reserved0  :8;
    word LogicalSectorLongerThan256Words  :1;
    word MultipleLogicalSectorsPerPhysicalSector  :1;
    word Reserved1  :2;
  } PhysicalLogicalSectorSize;
  word InterSeekDelay;
  word WorldWideName[4];
  word ReservedForWorldWideName128[4];
  word ReservedForTlcTechnicalReport;
  word WordsPerLogicalSector[2];
  struct {
    word ReservedForDrqTechnicalReport  :1;
    word WriteReadVerifySupported  :1;
    word Reserved01  :11;
    word Reserved1  :2;
  } CommandSetSupportExt;
  struct {
    word ReservedForDrqTechnicalReport  :1;
    word WriteReadVerifyEnabled  :1;
    word Reserved01  :11;
    word Reserved1  :2;
  } CommandSetActiveExt;
  word ReservedForExpandedSupportandActive[6];
  word MsnSupport  :2;
  word ReservedWord1274  :14;
  struct {
    word SecuritySupported  :1;
    word SecurityEnabled  :1;
    word SecurityLocked  :1;
    word SecurityFrozen  :1;
    word SecurityCountExpired  :1;
    word EnhancedSecurityEraseSupported  :1;
    word Reserved0  :2;
    word SecurityLevel  :1;
    word Reserved1  :7;
  } SecurityStatus;
  word ReservedWord129[31];
  struct {
    word MaximumCurrentInMA2  :12;
    word CfaPowerMode1Disabled  :1;
    word CfaPowerMode1Required  :1;
    word Reserved0  :1;
    word Word160Supported  :1;
  } CfaPowerModel;
  word ReservedForCfaWord161[8];
  struct {
    word SupportsTrim  :1;
    word Reserved0  :15;
  } DataSetManagementFeature;
  word ReservedForCfaWord170[6];
  word CurrentMediaSerialNumber[30];
  word ReservedWord206;
  word ReservedWord207[2];
  struct {
    word AlignmentOfLogicalWithinPhysical  :14;
    word Word209Supported  :1;
    word Reserved0  :1;
  } BlockAlignment;
  word WriteReadVerifySectorCountMode3Only[2];
  word WriteReadVerifySectorCountMode2Only[2];
  struct {
    word NVCachePowerModeEnabled  :1;
    word Reserved0  :3;
    word NVCacheFeatureSetEnabled  :1;
    word Reserved1  :3;
    word NVCachePowerModeVersion  :4;
    word NVCacheFeatureSetVersion  :4;
  } NVCacheCapabilities;
  word NVCacheSizeLSW;
  word NVCacheSizeMSW;
  word NominalMediaRotationRate;
  word ReservedWord218;
  struct {
    byte NVCacheEstimatedTimeToSpinUpInSeconds;
    byte Reserved;
  } NVCacheOptions;
  word ReservedWord220[35];
  word Signature  :8;
  word CheckSum  :8;
} IDENTIFY_DEVICE_DATA;

#endif  // __IDE_H

