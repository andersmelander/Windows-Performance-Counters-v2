unit amPerformanceCounters;

(*
  Example of usage:

  var
    PerformanceCounterProvider: TPerformanceCounterProvider;
    Category: TPerformanceCounterCategory;
    Counter1: TPerformanceCounterCounter;
    Counter2: TPerformanceCounterCounter;
  begin
    // Create provider
    PerformanceCounterProvider := TPerformanceCounterProvider.Create;
    PerformanceCounterProvider.ProviderGUID := '{B2A3E3B7-DDE1-421B-80B1-964BE3E3070A}';
    PerformanceCounterProvider.ProviderName := 'My demo provider';
    PerformanceCounterProvider.Version := '1.1';
    PerformanceCounterProvider.AutoRegister := True;
    PerformanceCounterProvider.AutoUpdate := True;

    // Create category
    Category := PerformanceCounterProvider.Categories.Add('test', 'test category', '{3445D1B7-A435-476C-ABF4-6C868F4E4773}');

    // Create a few counters
    Counter1 := Category.Counters.Add(pctCounterCounter, 'Foo', 'Number of Foos');
    Counter2 := Category.Counters.Add(pctCounterRawcount, 'Bar', 'Bar level');

    // Start provider
    PerformanceCounterProvider.StartProvider;

    // Change counter values
    Counter1.Increment;
    Counter2.Value := 123;

    // Stop provider
    PerformanceCounterProvider.StopProvider;

    // Clean up
    PerformanceCounterProvider.Free;
  end;
*)

interface

{$define INTERNAL_RESOURCE_MODULE}

uses
  Generics.Collections,
  Classes,
  Windows,
  SysUtils,
  TPerfLib,
  JwaWinperf;


// -----------------------------------------------------------------------------
//
//      TPerformanceCounterList<T>
//
// -----------------------------------------------------------------------------
type
  TPerformanceCounterList<T: class> = class
  private
    FItems: TObjectList<T>;
  protected
    function GetItem(Index: integer): T;
    function GetCount: integer;

    function Add(Item: T): integer;
    procedure Clear;
  public
    constructor Create;
    destructor Destroy; override;

    property Items[Index: integer]: T read GetItem; default;
    property Count: integer read GetCount;

    function GetEnumerator: TEnumerator<T>;
  end;


// -----------------------------------------------------------------------------
//
//      TPerformanceCounterType
//
// -----------------------------------------------------------------------------
// Performance counter types.
// -----------------------------------------------------------------------------
// Order is significant!
//
// Ordinal value can be mapped to the corresponding Win32 API type with
// the CounterTypeMap[] constant array.
// -----------------------------------------------------------------------------
// Documentation of the .NET values:
// https://msdn.microsoft.com/EN-US/library/4bcx21aa.aspx
// -----------------------------------------------------------------------------
type
  TPerformanceCounterType = (
    // Name                                Win32 symbol                         .NET symbol
    // ---------------------------------------------------------------------------------------------------------
    pctCounterCounter,                  // PERF_COUNTER_COUNTER                 RateOfCountsPerSecond32
    pctCounterTimer,                    // PERF_COUNTER_TIMER                   CounterTimer
    pctCounterQueuelenType,             // PERF_COUNTER_QUEUELEN_TYPE           CountPerTimeInterval32
    pctCounterLargeQueuelenType,        // PERF_COUNTER_LARGE_QUEUELEN_TYPE     CountPerTimeInterval64
    pctCounter100nsQueuelenType,        // PERF_COUNTER_100NS_QUEUELEN_TYPE
    pctCounterObjTimeQueuelenType,      // PERF_COUNTER_OBJ_TIME_QUEUELEN_TYPE
    pctCounterBulkCount,                // PERF_COUNTER_BULK_COUNT              RateOfCountsPerSecond64
    pctCounterText,                     // PERF_COUNTER_TEXT
    pctCounterRawCount,                 // PERF_COUNTER_RAWCOUNT                NumberOfItems32
    pctCounterLargeRawCount,            // PERF_COUNTER_LARGE_RAWCOUNT          NumberOfItems64
//  pctCounterRawcountHex,              // PERF_COUNTER_RAWCOUNT_HEX            NumberOfItemsHEX32
//  pctCounterLargeRawcountHex,         // PERF_COUNTER_LARGE_RAWCOUNT_HEX      NumberOfItemsHEX64
    pctSampleFraction,                  // PERF_SAMPLE_FRACTION                 SampleFraction
    pctSampleCounter,                   // PERF_SAMPLE_COUNTER                  SampleCounter
    pctCounterTimerInv,                 // PERF_COUNTER_TIMER_INV               CounterTimerInverse
    pctSampleBase,                      // PERF_SAMPLE_BASE                     SampleBase
    pctAverageTimer,                    // PERF_AVERAGE_TIMER                   AverageTimer32
    pctAverageBase,                     // PERF_AVERAGE_BASE                    AverageBase
    pctAverageBulk,                     // PERF_AVERAGE_BULK                    AverageCount64
    pctObjTimeTimer,                    // PERF_OBJ_TIME_TIMER
    pct100nsecTimer,                    // PERF_100NSEC_TIMER                   Timer100Ns
    pct100nsecTimerInv,                 // PERF_100NSEC_TIMER_INV               Timer100NsInverse
    pctCounterMultiTimer,               // PERF_COUNTER_MULTI_TIMER             CounterMultiTimer
    pctCounterMultiTimerInv,            // PERF_COUNTER_MULTI_TIMER_INV         CounterMultiTimerInverse
    pctCounterMultiBase,                // PERF_COUNTER_MULTI_BASE              CounterMultiBase
    pct100nsecMultiTimer,               // PERF_100NSEC_MULTI_TIMER             CounterMultiTimer100Ns
    pct100nsecMultiTimerInv,            // PERF_100NSEC_MULTI_TIMER_INV         CounterMultiTimer100NsInverse
    pctRawFraction,                     // PERF_RAW_FRACTION                    RawFraction
    pctLargeRawFraction,                // PERF_LARGE_RAW_FRACTION
    pctRawBase,                         // PERF_RAW_BASE                        RawBase
    pctLargeRawBase,                    // PERF_LARGE_RAW_BASE
    pctElapsedTime,                     // PERF_ELAPSED_TIME                    ElapsedTime
    pctCounterDelta,                    // PERF_COUNTER_DELTA                   CounterDelta32
    pctCounterLargeDelta,               // PERF_COUNTER_LARGE_DELTA             CounterDelta64
    pctPrecisionSystemTimer,            // PERF_PRECISION_SYSTEM_TIMER
    pctPrecision100nsTimer,             // PERF_PRECISION_100NS_TIMER
    pctPrecisionObjectTimer);           // PERF_PRECISION_OBJECT_TIMER


type
  // Forward declarations
  TPerformanceCounterProvider = class;
  TPerformanceCounterCategory = class;
  TPerformanceCounterCounter = class;

// -----------------------------------------------------------------------------
//
//      IPerformanceCounters
//
// -----------------------------------------------------------------------------
// High level abstraction for use with a factory pattern. Not used in this unit.
// -----------------------------------------------------------------------------
  IPerformanceCounters = interface
    ['{77637C95-7E25-4C92-B825-95A2576EAA21}']

    procedure InstallPerformanceCounters;
    procedure UninstallPerformanceCounters;

    procedure StartPerformanceCounters;

    function GetProvider: TPerformanceCounterProvider;
    property Provider: TPerformanceCounterProvider read GetProvider;
  end;

// -----------------------------------------------------------------------------
//
//      TPerformanceCounterProvider
//
// -----------------------------------------------------------------------------
// Encapsulates a performance counter provider.
// See:
// - https://msdn.microsoft.com/en-us/library/windows/desktop/aa965334(v=vs.85).aspx
// -----------------------------------------------------------------------------
  TPerformanceCounterInstanceType = (pcitSingleInstance, pcitMultiInstance, pcitSingleAggregate, pcitMultiAggregate, pcitSingleAggregateHistory);

  TPerformanceCounterProvider = class
  protected
    type
      TPerformanceCategoryList = class(TPerformanceCounterList<TPerformanceCounterCategory>)
      private
        FProvider: TPerformanceCounterProvider;
      public
        constructor Create(AProvider: TPerformanceCounterProvider);
        function Add(const AName, ADescription: string; const AGUID: TGUID; AInstanceType: TPerformanceCounterInstanceType = pcitSingleInstance): TPerformanceCounterCategory;
      end;
  strict private
    FProviderGUID: TGUID;
    FCategories: TPerformanceCategoryList;
    FVersion: string;
    FEnabled: boolean;
    FAutoUpdate: boolean;
    FAutoRegister: boolean;
    FResourceBaseIndex: DWORD;
    FProviderName: string;
    FApplicationIdentityBase: string;
    FInstallationFolder: string;
  strict private
    FHandle: THandle;
    FStarted: boolean;
  strict protected
    function GetApplicationIdentityBase: string;
    function GetApplicationIdentity: string;
    function GetInstallationFolder: string;

    procedure GenerateManifest(Stream: TStream);
    procedure GenerateAndSaveManifest(const Filename: string);
    procedure GenerateResourceModule(const Filename: string);
    procedure DoRegister(Log: boolean);
    procedure DoUnregister(Filename: string; Log: boolean);

    property ResourceBaseIndex: DWORD read FResourceBaseIndex;
  protected
    procedure Validate(Start: boolean);
    procedure CheckStarted; inline;
    procedure CheckNotStarted; inline;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Register(Log: boolean = False);
    procedure Unregister(Log: boolean = False);

    function Registered: boolean;
    function RegisteredVersion: string;

    procedure StartProvider;
    procedure StopProvider;

    property Handle: THandle read FHandle;

    property AutoRegister: boolean read FAutoRegister write FAutoRegister;
    property AutoUpdate: boolean read FAutoUpdate write FAutoUpdate;
    property Enabled: boolean read FEnabled write FEnabled;
    property Started: boolean read FStarted;

    property ApplicationIdentityBase: string read GetApplicationIdentityBase write FApplicationIdentityBase; // Optional. Defaults to module name excluding path and filetype
    property ProviderGUID: TGUID read FProviderGUID write FProviderGUID; // Required.

    // ProviderName is written to the manifest and stored in the registry by LODCTR but is not used by Windows or any tools
    property ProviderName: string read FProviderName write FProviderName; // Optional.


    // The Version string is used for auto update.
    // If AutoUpdate is True then the value is compared against the version value stored in the
    // registry (see RegisteredVersion). If the values differ then an update is performed.
    // Note: The persisted value of Version is bound to the value of ProviderName.
    property Version: string read FVersion write FVersion; // Optional. Defaults to "1.0"

    property ApplicationIdentity: string read GetApplicationIdentity;
    property InstallationFolder: string read GetInstallationFolder write FInstallationFolder; // Options. Defaults to %temp%

    property Categories: TPerformanceCategoryList read FCategories;
  end;


// -----------------------------------------------------------------------------
//
//      TPerformanceCounterCategory
//
// -----------------------------------------------------------------------------
// Encapsulates a counter set. Referred to here as a counter category.
// -----------------------------------------------------------------------------
  TPerformanceCounterInstance = class
  public
    Instance: PPERF_COUNTERSET_INSTANCE;
    Values: array of Int64;
  end;

  TPerformanceCounterCategory = class
  strict private
    type
      TPerformanceCounterSetLayout = record
        Info: PERF_COUNTERSET_INFO;
        Counters: array[0..0] of PERF_COUNTER_INFO;
      end;
      PPerformanceCounterSetLayout = ^TPerformanceCounterSetLayout;
  protected
    type
      TPerformanceCounterCounterList = class(TPerformanceCounterList<TPerformanceCounterCounter>)
      private
        FCategory: TPerformanceCounterCategory;
      public
        constructor Create(ACategory: TPerformanceCounterCategory);
        function Add(ACounterType: TPerformanceCounterType; const AName, ADescription: string): TPerformanceCounterCounter; overload;
        function Add(ACounterType: TPerformanceCounterType): TPerformanceCounterCounter; overload;
      end;
  strict private
    FProvider: TPerformanceCounterProvider;
    FCategoryGUID: TGUID;
    FCounters: TPerformanceCounterCounterList;
    FName: string;
    FDescription: string;
    FInstanceType: TPerformanceCounterInstanceType;
  strict private
    FNamedInstances: TDictionary<string, TPerformanceCounterInstance>;
    FInstances: TList<TPerformanceCounterInstance>;
    FInstanceCounter: integer;
    FSingleInstance: TPerformanceCounterInstance; // Convenience & performance
    FCounterSetLayout: PPerformanceCounterSetLayout;
    FCounterSetLayoutSize: integer;
  strict protected
    procedure CreateCounterSetLayout;
    procedure InitializeInstance(Instance: TPerformanceCounterInstance; const InstanceName: string; InstanceID: integer);

    function GetNamedInstance(const InstanceName: string): TPerformanceCounterInstance;
    function GetInstance(Index: integer): TPerformanceCounterInstance;
    function GetInstanceCount: integer;
    function GetMultiInstance: boolean;
  protected
    procedure Validate(Start: boolean);
    procedure Initialize;
    procedure Finalize;

    procedure CheckSingleInstance; inline;
    procedure CheckMultiInstance; inline;

    property SingleInstance: TPerformanceCounterInstance read FSingleInstance;
  public
    constructor Create(AProvider: TPerformanceCounterProvider; const AName, ADescription: string; const AGUID: TGUID; AInstanceType: TPerformanceCounterInstanceType);
    destructor Destroy; override;

    property Provider: TPerformanceCounterProvider read FProvider;

    property Name: string read FName;
    property Description: string read FDescription;
    property InstanceType: TPerformanceCounterInstanceType read FInstanceType;
    property CategoryGUID: TGUID read FCategoryGUID;

    property MultiInstance: boolean read GetMultiInstance;

    property Instances[const Name: string]: TPerformanceCounterInstance read GetNamedInstance; default;
    property Instances[Index: integer]: TPerformanceCounterInstance read GetInstance; default;
    property InstanceCount: integer read GetInstanceCount;

    property Counters: TPerformanceCounterCounterList read FCounters;
  end;


// -----------------------------------------------------------------------------
//
//      TPerformanceCounterValue
//
// -----------------------------------------------------------------------------
// Encapsulates a single counter value of a single instance.
// -----------------------------------------------------------------------------
  TPerformanceCounterValueRec = record
  private
    FValue: Int64;
    function GetValue: int64;
    procedure SetValue(const Value: int64);
  public
    property RawValue: int64 read FValue write FValue;
    property Value: int64 read GetValue write SetValue;

    procedure Increment; overload;
    procedure Increment(Delta: int64); overload;

    procedure Decrement; overload;
    procedure Decrement(Delta: int64); overload;
  end;

  TPerformanceCounterValue = ^TPerformanceCounterValueRec;


// -----------------------------------------------------------------------------
//
//      TPerformanceCounterCounter
//
// -----------------------------------------------------------------------------
// Represents a single counter spanning one or more instances.
// -----------------------------------------------------------------------------
  TPerformanceCounterDisplayOption = (pcdoHide, pcdoNoDigitSeparator, pcdoDisplayAsReal, pcdoDisplayAsHex);
  TPerformanceCounterDisplayOptions = set of TPerformanceCounterDisplayOption;

  TPerformanceCounterDetailLevel = (pcdlNovice, pcdlAdvanced);

  TPerformanceCounterAggregate = (pcaNone, pcaMax, pcaMin, pcaAverage, pcaSum);

  TPerformanceCounterCounter = class
  strict private
    FName: string;
    FDescription: string;
    FType: TPerformanceCounterType;
    FDetailLevel: TPerformanceCounterDetailLevel;
    FDisplayOptions: TPerformanceCounterDisplayOptions;
    FScale: integer;
    FMultiplierCounter: TPerformanceCounterCounter;
    FTimeCounter: TPerformanceCounterCounter;
    FFrequencyCounter: TPerformanceCounterCounter;
    FBaseCounter: TPerformanceCounterCounter;
    FAggregate: TPerformanceCounterAggregate;
  strict private
    FCategory: TPerformanceCounterCategory;
    FCounterID: integer;
  strict private
    function GetInstanceValue(Instance: TPerformanceCounterInstance): TPerformanceCounterValue;
    function GetNamedInstanceValue(const Name: string): TPerformanceCounterValue;
    function GetValue: TPerformanceCounterValue;
  strict protected
    procedure SetBaseCounter(const Value: TPerformanceCounterCounter);
    procedure SetFrequencyCounter(const Value: TPerformanceCounterCounter);
    procedure SetMultiplierCounter(const Value: TPerformanceCounterCounter);
    procedure SetTimeCounter(const Value: TPerformanceCounterCounter);
    procedure SetScale(const Value: integer);
    function GetIsHidden: boolean;
    function GetDisplayOptions: TPerformanceCounterDisplayOptions;
  protected
    procedure Validate(Start: boolean);
    procedure Initialize;
    procedure Finalize;
    procedure InitializeInstance(Instance: TPerformanceCounterInstance);
    procedure FinalizeInstance(Instance: TPerformanceCounterInstance);
  public
    constructor Create(ACategory: TPerformanceCounterCategory; ACounterID: integer; const AName, ADescription: string; ACounterType: TPerformanceCounterType);

    property Category: TPerformanceCounterCategory read FCategory;

    property Name: string read FName;
    property Description: string read FDescription;
    property CounterType: TPerformanceCounterType read FType;
    property DisplayOptions: TPerformanceCounterDisplayOptions read GetDisplayOptions write FDisplayOptions;
    property DetailLevel: TPerformanceCounterDetailLevel read FDetailLevel write FDetailLevel;
    property Scale: integer read FScale write SetScale;

    property Aggregate: TPerformanceCounterAggregate read FAggregate write FAggregate;

    property BaseCounter: TPerformanceCounterCounter read FBaseCounter write SetBaseCounter;
    property MultiplierCounter: TPerformanceCounterCounter read FMultiplierCounter write SetMultiplierCounter;
    property FrequencyCounter: TPerformanceCounterCounter read FFrequencyCounter write SetFrequencyCounter;
    property TimeCounter: TPerformanceCounterCounter read FTimeCounter write SetTimeCounter;

    property CounterID: integer read FCounterID;
    property IsHidden: boolean read GetIsHidden;

    property Value: TPerformanceCounterValue read GetValue;
    property Instances[const Name: string]: TPerformanceCounterValue read GetNamedInstanceValue; default;
    property Instances[Instance: TPerformanceCounterInstance]: TPerformanceCounterValue read GetInstanceValue; default;
  end;


// -----------------------------------------------------------------------------

type
  // All explicit exceptions raised by this library is of type EPerfCount
  EPerfCountProvider = class(Exception);

// -----------------------------------------------------------------------------

const
  // Registry root of the Windows performance counter V2 database
  sPerformanceCounterRegProviderVersionKey = '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\_V2Providers\';
  // Registry key used to determine if a provider has been installed (the actual value isn't used)
  sPerformanceCounterRegProviderRegistrationIndicator = 'ApplicationIdentity';
  // Registry key where the ProviderName and Version is stored
  sPerformanceCounterRegProviderName = 'ProviderName';


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

implementation

uses
  ComObj,
  XmlDoc,
  XmlIntf,
  IOUtils,
  Registry,
  ActiveX,
  ShellAPI,
  TypInfo,
  SyncObjs,

  //LUtils, // DONE : Eliminate dependency. Poorly implemented.
  CLog; // TODO : Get rid of this dependency.


{$ifdef INTERNAL_RESOURCE_MODULE}
const
  // The following is the content of the file specified by the sPerformanceCounterResourceModuleStub constant.
  // It should be a minimal (i.e. no code) PE module containing nothing but a resource section without any resources.
  sPerformanceCounterResourceModuleData : AnsiString =
    #$4D#$5A#$90#$00#$03#$00#$00#$00#$04#$00#$00#$00#$FF#$FF#$00#$00#$B8#$00#$00#$00#$00#$00#$00#$00#$40#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$B0#$00#$00#$00+
    #$0E#$1F#$BA#$0E#$00#$B4#$09#$CD#$21#$B8#$01#$4C#$CD#$21#$54#$68#$69#$73#$20#$70#$72#$6F#$67#$72#$61#$6D#$20#$63#$61#$6E#$6E#$6F+
    #$74#$20#$62#$65#$20#$72#$75#$6E#$20#$69#$6E#$20#$44#$4F#$53#$20#$6D#$6F#$64#$65#$2E#$0D#$0D#$0A#$24#$00#$00#$00#$00#$00#$00#$00+
    #$37#$CF#$3C#$DF#$73#$AE#$52#$8C#$73#$AE#$52#$8C#$73#$AE#$52#$8C#$E1#$F0#$AD#$8C#$72#$AE#$52#$8C#$E4#$F0#$50#$8D#$72#$AE#$52#$8C+
    #$52#$69#$63#$68#$73#$AE#$52#$8C#$00#$00#$00#$00#$00#$00#$00#$00#$50#$45#$00#$00#$4C#$01#$02#$00#$B0#$66#$81#$5A#$00#$00#$00#$00+
    #$00#$00#$00#$00#$E0#$00#$02#$21#$0B#$01#$0E#$00#$00#$00#$00#$00#$00#$04#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$10#$00#$00+
    #$00#$10#$00#$00#$00#$00#$00#$10#$00#$10#$00#$00#$00#$02#$00#$00#$06#$00#$00#$00#$00#$00#$00#$00#$06#$00#$00#$00#$00#$00#$00#$00+
    #$00#$30#$00#$00#$00#$02#$00#$00#$00#$00#$00#$00#$02#$00#$40#$05#$00#$00#$10#$00#$00#$10#$00#$00#$00#$00#$10#$00#$00#$10#$00#$00+
    #$00#$00#$00#$00#$10#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$20#$00#$00#$10#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$10#$00#$00#$1C#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$2E#$72#$64#$61#$74#$61#$00#$00#$70#$00#$00#$00#$00#$10#$00#$00#$00#$02#$00#$00#$00#$02#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$40#$00#$00#$40#$2E#$72#$73#$72#$63#$00#$00#$00#$10#$00#$00#$00#$00#$20#$00#$00+
    #$00#$02#$00#$00#$00#$04#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$40#$00#$00#$40#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$B0#$66#$81#$5A#$00#$00#$00#$00#$0D#$00#$00#$00#$40#$00#$00#$00#$1C#$10#$00#$00#$1C#$02#$00#$00#$00#$00#$00#$00+
    #$00#$10#$00#$00#$1C#$00#$00#$00#$2E#$72#$64#$61#$74#$61#$00#$00#$1C#$10#$00#$00#$54#$00#$00#$00#$2E#$72#$64#$61#$74#$61#$24#$7A+
    #$7A#$7A#$64#$62#$67#$00#$00#$00#$00#$20#$00#$00#$10#$00#$00#$00#$2E#$72#$73#$72#$63#$24#$30#$31#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00+
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00;
{$else INTERNAL_RESOURCE_MODULE}
const
  sPerformanceCounterResourceModuleStub = 'ResourceModule.dll';
{$endif INTERNAL_RESOURCE_MODULE}

// Map framework counter type values to Win32 API values.
const
  InstanceTypeMap: array[TPerformanceCounterInstanceType] of DWORD = (
    PERF_COUNTERSET_SINGLE_INSTANCE,
    PERF_COUNTERSET_MULTI_INSTANCES,
    PERF_COUNTERSET_SINGLE_AGGREGATE,
    PERF_COUNTERSET_MULTI_AGGREGATE,
    PERF_COUNTERSET_SINGLE_AGGREGATE_HISTORY);

  CounterTypeMap: array[TPerformanceCounterType] of DWORD = (
    PERF_COUNTER_COUNTER,
    PERF_COUNTER_TIMER,
    PERF_COUNTER_QUEUELEN_TYPE,
    PERF_COUNTER_LARGE_QUEUELEN_TYPE,
    PERF_COUNTER_100NS_QUEUELEN_TYPE,
    PERF_COUNTER_OBJ_TIME_QUEUELEN_TYPE,
    PERF_COUNTER_BULK_COUNT,
    PERF_COUNTER_TEXT,
    PERF_COUNTER_RAWCOUNT,
    PERF_COUNTER_LARGE_RAWCOUNT,
    // PERF_COUNTER_RAWCOUNT_HEX,
    // PERF_COUNTER_LARGE_RAWCOUNT_HEX,
    PERF_SAMPLE_FRACTION,
    PERF_SAMPLE_COUNTER,
    PERF_COUNTER_TIMER_INV,
    PERF_SAMPLE_BASE,
    PERF_AVERAGE_TIMER,
    PERF_AVERAGE_BASE,
    PERF_AVERAGE_BULK,
    PERF_OBJ_TIME_TIMER,
    PERF_100NSEC_TIMER,
    PERF_100NSEC_TIMER_INV,
    PERF_COUNTER_MULTI_TIMER,
    PERF_COUNTER_MULTI_TIMER_INV,
    PERF_COUNTER_MULTI_BASE,
    PERF_100NSEC_MULTI_TIMER,
    PERF_100NSEC_MULTI_TIMER_INV,
    PERF_RAW_FRACTION,
    PERF_LARGE_RAW_FRACTION,
    PERF_RAW_BASE,
    PERF_LARGE_RAW_BASE,
    PERF_ELAPSED_TIME,
    PERF_COUNTER_DELTA,
    PERF_COUNTER_LARGE_DELTA,
    PERF_PRECISION_SYSTEM_TIMER,
    PERF_PRECISION_100NS_TIMER,
    PERF_PRECISION_OBJECT_TIMER);

  DetailLevelMap: array[TPerformanceCounterDetailLevel] of WORD = (
    PERF_DETAIL_NOVICE,
    PERF_DETAIL_ADVANCED);

// -----------------------------------------------------------------------------
//
//      ShellExecute
//
// -----------------------------------------------------------------------------
function ShellExecute(const FileName: string; const Operation: string = 'open'; const Parameters: string = ''; ShowCmd: Integer = SW_SHOWNORMAL; Wait: boolean = False; const Directory: string = ''): boolean;
var
  ShellExecuteInfo: TShellExecuteInfo;
begin
  FillChar(ShellExecuteInfo, SizeOf(ShellExecuteInfo), 0);
  ShellExecuteInfo.cbSize := SizeOf(ShellExecuteInfo);
  ShellExecuteInfo.fMask := SEE_MASK_FLAG_NO_UI or SEE_MASK_NOZONECHECKS;
  if (Wait) then
    ShellExecuteInfo.fMask := ShellExecuteInfo.fMask or SEE_MASK_NOCLOSEPROCESS;
  if (Operation <> '') then
    ShellExecuteInfo.lpVerb := PChar(Operation);
  if (FileName <> '') then
    ShellExecuteInfo.lpFile := PChar(FileName);
  if (Parameters <> '') then
    ShellExecuteInfo.lpParameters := PChar(Parameters);
  if (Directory <> '') then
    ShellExecuteInfo.lpDirectory := PChar(Directory);
  ShellExecuteInfo.nShow := ShowCmd;

  // SaveCursor(crAppStart);

  Result := ShellAPI.ShellExecuteEx(@ShellExecuteInfo);

  if (Result) and (Wait) then
    try
      WaitForSingleObject(ShellExecuteInfo.hProcess, INFINITE);
    finally
      CloseHandle(ShellExecuteInfo.hProcess);
    end;
end;

// -----------------------------------------------------------------------------
//
//      Registry utilities
//
// -----------------------------------------------------------------------------
procedure CreateRegKey(const Key, ValueName, Value: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;

    if (not Reg.OpenKey(Key, True)) then
      RaiseLastOSError;

    Reg.WriteString(ValueName, Value);
  finally
    Reg.Free;
  end;
end;

function GetRegStringValue(const Key, ValueName: string): string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;

    if (Reg.OpenKeyReadOnly(Key)) then
      Result := Reg.ReadString(ValueName)
    else
      Result := '';
  finally
    Reg.Free;
  end;
end;

procedure DeleteRegKeyValue(const Key, ValueName: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;

    if (Reg.OpenKey(Key, False)) then
      Reg.DeleteValue(ValueName);
  finally
    Reg.Free;
  end;
end;

// -----------------------------------------------------------------------------
//
//      TPerformanceCounterList<T>
//
// -----------------------------------------------------------------------------
function TPerformanceCounterList<T>.Add(Item: T): integer;
begin
  Result := FItems.Add(Item);
end;

procedure TPerformanceCounterList<T>.Clear;
begin
  FItems.Clear;
end;

constructor TPerformanceCounterList<T>.Create;
begin
  inherited Create;

  FItems := TObjectList<T>.Create;
end;

destructor TPerformanceCounterList<T>.Destroy;
begin
  FreeAndNil(FItems);

  inherited;
end;

function TPerformanceCounterList<T>.GetCount: integer;
begin
  Result := FItems.Count;
end;

function TPerformanceCounterList<T>.GetEnumerator: TEnumerator<T>;
begin
  Result := FItems.GetEnumerator;
end;

function TPerformanceCounterList<T>.GetItem(Index: integer): T;
begin
  Result := FItems[Index];
end;

// -----------------------------------------------------------------------------
//
//      TPerformanceCounterProvider
//
// -----------------------------------------------------------------------------
constructor TPerformanceCounterProvider.Create;
begin
  inherited Create;

  FCategories := TPerformanceCategoryList.Create(Self);

  FVersion := '1.0';
  FEnabled := True;
end;

destructor TPerformanceCounterProvider.Destroy;
begin
  StopProvider;

  FreeAndNil(FCategories);

  inherited;
end;

// -----------------------------------------------------------------------------

constructor TPerformanceCounterProvider.TPerformanceCategoryList.Create(AProvider: TPerformanceCounterProvider);
begin
  inherited Create;
  FProvider := AProvider;
end;

function TPerformanceCounterProvider.TPerformanceCategoryList.Add(const AName, ADescription: string; const AGUID: TGUID; AInstanceType: TPerformanceCounterInstanceType): TPerformanceCounterCategory;
var
  i: integer;
begin
  FProvider.CheckNotStarted;

  if (AName = '') then
    raise EPerfCountProvider.Create('TPerformanceCounterCategory.Name requires a value');

  if (ADescription = '') then
    raise EPerfCountProvider.Create('TPerformanceCounterCategory.Description requires a value');

  for i := 0 to Count-1 do
  begin
    if (Items[i].Name = AName) then
      raise EPerfCountProvider.CreateFmt('Duplicate counter category name: %s', [AName]);

    if (Items[i].CategoryGUID = AGUID) then
      raise EPerfCountProvider.CreateFmt('Duplicate counter category GUID: %s', [GuidToString(AGUID)]);
  end;

  Result := TPerformanceCounterCategory.Create(FProvider, AName, ADescription, AGUID, AInstanceType);

  inherited Add(Result);
end;

// -----------------------------------------------------------------------------

function TPerformanceCounterProvider.GetApplicationIdentity: string;
begin
  Result := ApplicationIdentityBase +'.resources.dll';
end;

function TPerformanceCounterProvider.GetApplicationIdentityBase: string;
begin
  Result := FApplicationIdentityBase;
  if (Result = '') then
    Result := TPath.GetFileNameWithoutExtension(GetModuleName(hInstance))
end;

function TPerformanceCounterProvider.GetInstallationFolder: string;
begin
  Result := IncludeTrailingPathDelimiter(FInstallationFolder);
  if (Result = '\') then
    Result := TPath.GetTempPath;
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterProvider.GenerateAndSaveManifest(const Filename: string);
var
  ManifestStream: TStringStream;
begin
  ManifestStream := TStringStream.Create('', TEncoding.UTF8);
  try

    GenerateManifest(ManifestStream);

    ManifestStream.SaveToFile(Filename);

  finally
    ManifestStream.Free;
  end;
end;

procedure TPerformanceCounterProvider.GenerateManifest(Stream: TStream);
// Performance Counters Schema:
// https://msdn.microsoft.com/en-us/library/windows/desktop/aa373092(v=vs.85).aspx
const
  sInstanceTypes: array[TPerformanceCounterInstanceType] of string = ('single', 'multiple', 'globalAggregate', 'multipleAggregate', 'globalAggregateHistory');

  sCounterTypes: array[TPerformanceCounterType] of string = (
    'perf_counter_counter',
    'perf_counter_timer',
    'perf_counter_queuelen_type',
    'perf_counter_large_queuelen_type',
    'perf_counter_100ns_queuelen_type',
    'perf_counter_obj_time_queuelen_type',
    'perf_counter_bulk_count',
    'perf_counter_text',
    'perf_counter_rawcount',
    'perf_counter_large_rawcount',
    // 'perf_counter_rawcount_hex',
    // 'perf_counter_large_rawcount_hex',
    'perf_sample_fraction',
    'perf_sample_counter',
    'perf_counter_timer_inv',
    'perf_sample_base',
    'perf_average_timer',
    'perf_average_base',
    'perf_average_bulk',
    'perf_obj_time_timer',
    'perf_100nsec_timer',
    'perf_100nsec_timer_inv',
    'perf_counter_multi_timer',
    'perf_counter_multi_timer_inv',
    'perf_counter_multi_base',
    'perf_100nsec_multi_timer',
    'perf_100nsec_multi_timer_inv',
    'perf_raw_fraction',
    'perf_large_raw_fraction',
    'perf_raw_base',
    'perf_large_raw_base',
    'perf_elapsed_time',
    'perf_counter_delta',
    'perf_counter_large_delta',
    'perf_precision_system_timer',
    'perf_precision_100ns_timer',
    'perf_precision_object_timer');

  sDetailLevel: array[TPerformanceCounterDetailLevel] of string = ('standard', 'advanced');

  sDisplayOptions: array[TPerformanceCounterDisplayOption] of string = ('noDisplay', 'noDigitGrouping', 'displayAsReal', 'displayAsHex');

  sAggregates: array[TPerformanceCounterAggregate] of string = ('undefined', 'max', 'min', 'average', 'sum');
var
  XML: IXMLDocument;
  Node: IXMLNode;

  ProviderNode: IXMLNode;
  s: string;

  Category: TPerformanceCounterCategory;
  CategoryNode: IXMLNode;
  nCategory: integer;

  Counter: TPerformanceCounterCounter;
  CounterNode: IXMLNode;

  Option: TPerformanceCounterDisplayOption;
begin
  XML := NewXMLDocument;
  try
    XML.Options := [doNodeAutoCreate, doNodeAutoIndent];

    Node := XML.AddChild('instrumentationManifest');
    Node := Node.AddChild('instrumentation');
    Node := Node.AddChild('counters');

    // provider Complex Type
    // https://msdn.microsoft.com/en-us/library/windows/desktop/ee781351(v=vs.85).aspx
    ProviderNode := Node.AddChild('provider');

    ProviderNode.Attributes['applicationIdentity'] := ApplicationIdentity;
    // Both name and version is stored in the ProviderName string. The string is persisted in the registry but isn't used by Windows.
    if (ProviderName <> '') or (Version <> '') then
    begin
      if (ProviderName <> '') then
      begin
        s := ProviderName;
        if (Version <> '') then
          s := s + ' ' + Version;
      end else
        s := Version;
      ProviderNode.Attributes['providername'] := s;
    end;
    ProviderNode.Attributes['providerGuid'] := GuidToString(ProviderGUID);
    if (ResourceBaseIndex <> 0) then
      ProviderNode.Attributes['resourceBase'] := IntToStr(ResourceBaseIndex);

    nCategory := 0;
    for Category in Categories do
    begin
      // counterSet Complex Type
      // https://msdn.microsoft.com/en-us/library/windows/desktop/ee781341(v=vs.85).aspx
      CategoryNode := ProviderNode.AddChild('counterSet');

      CategoryNode.Attributes['guid'] := GuidToString(Category.CategoryGUID);
      CategoryNode.Attributes['name'] := Category.Name;
      CategoryNode.Attributes['description'] := Category.Description;
      CategoryNode.Attributes['instances'] := sInstanceTypes[Category.InstanceType];

      CategoryNode.Attributes['symbol'] := Format('cs%d', [nCategory]);
      CategoryNode.Attributes['uri'] := GuidToString(Category.CategoryGUID);

      for Counter in Category.Counters do
      begin
        // counter Complex Type
        // https://msdn.microsoft.com/en-us/library/windows/desktop/ee781345(v=vs.85).aspx
        CounterNode := CategoryNode.AddChild('counter');

        CounterNode.Attributes['id'] := IntToStr(Counter.CounterID);
        if (not Counter.IsHidden) then
          CounterNode.Attributes['name'] := Counter.Name;
        if (not Counter.IsHidden) then
          CounterNode.Attributes['description'] := Counter.Description;
        CounterNode.Attributes['type'] := sCounterTypes[Counter.CounterType];
        CounterNode.Attributes['detailLevel'] := sDetailLevel[Counter.DetailLevel];
        if (Counter.Scale <> 0) then
          CounterNode.Attributes['defaultScale'] := Counter.Scale;
        if (Counter.Aggregate <> pcaNone) then
          CounterNode.Attributes['aggregate'] := sAggregates[Counter.Aggregate];
        if (Counter.BaseCounter <> nil) then
          CounterNode.Attributes['baseID'] := Counter.BaseCounter.CounterID;
        if (Counter.MultiplierCounter <> nil) then
          CounterNode.Attributes['multiCounterID'] := Counter.MultiplierCounter.CounterID;
        if (Counter.FrequencyCounter <> nil) then
          CounterNode.Attributes['perfFreqID'] := Counter.FrequencyCounter.CounterID;
        if (Counter.TimeCounter <> nil) then
          CounterNode.Attributes['perfTimeID'] := Counter.TimeCounter.CounterID;

        CounterNode.Attributes['uri'] := GuidToString(Category.CategoryGUID)+'.'+IntToStr(Counter.CounterID);

        Node := CounterNode.AddChild('counterAttributes');
        Node.ChildNodes.Nodes['counterAttribute'].Attributes['name'] := 'reference';

        // counterAttribute Complex Type
        // https://msdn.microsoft.com/en-us/library/windows/desktop/ee781339(v=vs.85).aspx
        for Option in Counter.DisplayOptions do
          Node.ChildNodes.Nodes['counterAttribute'].Attributes['name'] := sDisplayOptions[Option];
      end;

      inc(nCategory);
    end;

    XML.SaveToStream(Stream);
  finally
    XML := nil;
  end;
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterProvider.GenerateResourceModule(const Filename: string);

  procedure CreateResourceStringList(Strings: TStrings);
  var
    Category: TPerformanceCounterCategory;
    Counter: TPerformanceCounterCounter;
  begin
    // Generate a list performance counter text strings that match the output from the CTRPP tool.
    Strings.Add(''); // The CTRPP strings starts at #1

    for Category in Categories do
    begin
      Strings.Add(Category.Name);
      Strings.Add(Category.Name);

      Strings.Add(Category.Description);
      Strings.Add('');

      for Counter in Category.Counters do
      begin
        // Skip hidden counters
        if (Counter.IsHidden) then
          continue;

        Strings.Add(Counter.Name);
        Strings.Add(Counter.Name);

        Strings.Add(Counter.Description);
        Strings.Add('');
      end;
    end;
  end;

  procedure WriteResourceData(Strings: TStrings);
  var
    ResourceHandle: Cardinal;
    Stream: TMemoryStream;
    i: integer;
    Size: Word;
    s: string;
    Count: integer;
  begin
    (*
    ** Updates an empty PE module with the performance counter string list.
    *)
    ResourceHandle := BeginUpdateResource(PChar(Filename), True);
    if (ResourceHandle = 0) then
      RaiseLastOSError;
    try

      Stream := TMemoryStream.Create;
      try

        Count := (Strings.Count + 15) div 16 * 16;

        for i := 0 to Count-1 do
        begin
          if (i < Strings.Count) then
          begin
            s := Strings[i];
            Size := Length(s);

            // Resource string format is: [length:dword][unicode string data]
            Stream.Write(Size, SizeOf(Size));
            if (Size <> 0) then
              Stream.Write(PChar(s)^, Size * SizeOf(Char));
          end else
          begin
            Size := 0;
            Stream.Write(Size, SizeOf(Size));
          end;

          // Write resource strings in blocks of 16 strings
          if ((i+1) mod 16 = 0) then
          begin
            UpdateResource(ResourceHandle, RT_STRING, MAKEINTRESOURCE((i+1) div 16), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), Stream.Memory, Stream.Size);
            Stream.Size := 0;
          end;
        end;

      finally
        Stream.Free;
      end;
      EndUpdateResourceW(ResourceHandle, False);

    except
      EndUpdateResourceW(ResourceHandle, True);
      raise;
    end;
  end;

var
  Strings: TStrings;
{$ifdef INTERNAL_RESOURCE_MODULE}
  FileStream: TFileStream;
{$endif INTERNAL_RESOURCE_MODULE}
begin
  Strings := TStringList.Create;
  try
    CreateResourceStringList(Strings);

    // TODO : Handle access denied etc. Retry operation with random file name.
{$ifdef INTERNAL_RESOURCE_MODULE}
    FileStream := TFileStream.Create(Filename, fmCreate);
    try

      FileStream.WriteBuffer(PAnsiChar(sPerformanceCounterResourceModuleData)^, Length(sPerformanceCounterResourceModuleData));

    finally
      FileStream.Free;
    end;
{$else INTERNAL_RESOURCE_MODULE}
    if (not TFile.Exist(sPerformanceCounterResourceModuleStub)) then
      raise EPerfCountProvider.CreateFmt('Performance counter resource module stub file not found: %s', [sPerformanceCounterResourceModuleStub]);

    TFile.Copy(sPerformanceCounterResourceModuleStub, Filename, True);
{$endif INTERNAL_RESOURCE_MODULE}

    WriteResourceData(Strings);
  finally
    Strings.Free;
  end;

  FResourceBaseIndex := 1;
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterProvider.DoRegister(Log: boolean);
var
  ResourceFilename: string;
  ManifestFilename: string;
  s: string;
  LogFilename: string;
(*
  Module: HModule;
  LogStrings: TStringList;
  LogText: string;
*)
begin
  // Generate resource module
  ResourceFilename := InstallationFolder + ApplicationIdentity;
  GenerateResourceModule(ResourceFilename);
  ASSERT(TFile.Exists(ResourceFilename));

  // Generate manifest
  ManifestFilename := TPath.ChangeExtension(ResourceFilename, '.xml');
  GenerateAndSaveManifest(ManifestFilename);
  ASSERT(TFile.Exists(ManifestFilename));

  if (Registered) then
  begin
    if (Version <> RegisteredVersion) then
    begin
      if (not AutoUpdate) then
      begin
        s := Format('Performance counter "%s" is already registered with a different version but has not been configured to auto update.'#13' This version: %s'#13'Existing version: %s', [GuidToString(ProviderGUID), Version, RegisteredVersion]);
        if (Log) then
          AddToErrorMsg(s)
        else
          raise EPerfCountProvider.Create(s);

        exit;
      end;

      if (Log) then
      begin
        s := Format('Performance counter "%s" is already registered with a different version which will be automatically unregistered.'#13' This version: %s'#13'Existing version: %s', [GuidToString(ProviderGUID), Version, RegisteredVersion]);
        AddToInfoMsg(s);
      end;

      DoUnregister(ManifestFilename, Log);
    end else
    if (Log) then
    begin
      s := Format('Performance counter "%s" is already registered and up to date.', [GuidToString(ProviderGUID)]);
      AddToInfoMsg(s);
    end;
  end;

  // Register counters
  // 'RunAs' parameter allows to run command under Administrator
  LogFilename := TPath.ChangeExtension(ManifestFilename, '.log');
  s := Format('/C LODCTR "/M:%s" > "%s"', [ManifestFilename, LogFilename]);

  if (ShellExecute('cmd.exe', 'RunAs', s, SW_HIDE, True, TPath.GetDirectoryName(ManifestFilename))) then
  begin
    if (Log) then
      AddToInfoMsg(Format('"%s" performance counters was successfully installed.'#13'ID:%s', [ApplicationIdentity, GuidToString(ProviderGUID)]));
  end else
  if (Log) then
  begin
    s := SysErrorMessage(GetLastError);
    AddToErrorMsg(Format('Failed to install the "%s" performance counters from %s.'#13'ID:%s'#13'Error:%s', [ApplicationIdentity, ManifestFilename, GuidToString(ProviderGUID), s]));
    exit;
  end else
    RaiseLastOSError;

  // Verify registration
  (* Disabled as the test consistently fails (for unknown reasons, empty log) on the build server.
  if (GetRegStringValue(sPerformanceCounterRegProviderVersionKey + GUIDToString(ProviderGUID), sPerformanceCounterRegProviderRegistrationIndicator) = '') then
  begin
    // Try to get STDOUT/STDERR output from command line
    if (FileExists(LogFilename)) then
    begin
      LogStrings := TStringList.Create;
      try
        LogStrings.LoadFromFile(LogFilename);
        LogText := LogStrings.Text;
      finally
        LogStrings.Free;
      end;
    end else
      LogText := '';

    // Verify that the DLL can be loaded as a resource
    Module := LoadLibraryEx(PChar(ResourceFilename), 0, LOAD_LIBRARY_AS_DATAFILE);
    if (Module = 0) then
    begin
      s := SysErrorMessage(GetLastError);
      raise EPerfCountProvider.CreateFmt('Failed to load resource DLL during verification of performance counter registration: "%s".'#13'ID:%s'#13'Error:%s'#13'Log:%s', [ResourceFilename, GUIDToString(ProviderGUID), s, LogText]);
    end else
      FreeLibrary(Module);

    raise EPerfCountProvider.CreateFmt('Failed to verify performance counter registration of "%s".'#13'ID:%s'#13'Log:%s', [ManifestFilename, GUIDToString(ProviderGUID), LogText]);
  end;
  *)
end;

procedure TPerformanceCounterProvider.DoUnregister(Filename: string; Log: boolean);
var
  s: string;
begin
  // 'RunAs' parameter allows to run command under Administrator
  if (ShellExecute('cmd.exe', 'RunAs', '/C UNLODCTR /M:' + Filename, SW_HIDE, True)) then
  begin
    if (Log) then
      AddToInfoMsg(Format('"%s" performance counters was successfully uninstalled.'#13'%s', [GuidToString(ProviderGUID), ApplicationIdentity]));
  end else
  if (Log) then
  begin
    s := SysErrorMessage(GetLastError);
    AddToErrorMsg(Format('Failed to uninstall the "%s" performance counters from %s.'#13'%s', [GuidToString(ProviderGUID), ApplicationIdentity, s]));
  end else
    RaiseLastOSError;
end;

procedure TPerformanceCounterProvider.Register(Log: boolean);
begin
  // If the provider doesn't contain any categories then the LODCTR tool will claim success
  // but will not actually do anything which will cause our verification to fail.
  // Output from LODCTR:
  //   Warning: No <counterSet> element within <provider> element.
  //   Info: Successfully installed performance counters in [filename]
  if (FCategories.Count = 0) then
    exit;

  Validate(False);

  DoRegister(Log);
end;

procedure TPerformanceCounterProvider.Unregister(Log: boolean);
var
  Filename: string;
begin
  Validate(False);

  // Generate manifest
  Filename := InstallationFolder + ApplicationIdentity;
  Filename := TPath.ChangeExtension(Filename, '.xml');
  GenerateAndSaveManifest(Filename);
  ASSERT(TFile.Exists(Filename));

  DoUnregister(Filename, Log);
end;

// -----------------------------------------------------------------------------

function TPerformanceCounterProvider.Registered: boolean;
begin
  Result := (GetRegStringValue(sPerformanceCounterRegProviderVersionKey + GUIDToString(ProviderGUID), sPerformanceCounterRegProviderRegistrationIndicator) <> '');
end;

// -----------------------------------------------------------------------------

function TPerformanceCounterProvider.RegisteredVersion: string;
begin
  Result := GetRegStringValue(sPerformanceCounterRegProviderVersionKey + GUIDToString(ProviderGUID), sPerformanceCounterRegProviderName);

  // Version is stored in ProviderName key in the format [ProviderName][Space][Version]
  if (FProviderName <> '') then
  begin
    if (Copy(Result, 1, Length(FProviderName)) = FProviderName+' ') then
      Delete(Result, 1, Length(FProviderName)+1)
    else
      Result := '';
  end;
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterProvider.Validate(Start: boolean);
var
  Category: TPerformanceCounterCategory;
begin
  // Perform preflight check

  if (FProviderGUID = GUID_NULL) then
    raise EPerfCountProvider.Create('TPerformanceCounterProvider.ProviderGUID requires a value');

  if (Start) and (FCategories.Count = 0) then
    raise EPerfCountProvider.Create('Provider requires at least one category');

  for Category in FCategories do
    Category.Validate(Start);
end;

procedure TPerformanceCounterProvider.StartProvider;
var
  Category: TPerformanceCounterCategory;
begin
  if (FStarted) then
    raise EPerfCountProvider.Create('Provider has already been started');

  if (not FEnabled) then
    raise EPerfCountProvider.Create('Provider is not enabled');

  ASSERT(FHandle = 0);

  // Perform preflight check
  Validate(True);


  // Auto-register and auto-update
  if ((FAutoRegister) and (not Registered)) or ((FAutoUpdate) and (Registered) and (FVersion <> RegisteredVersion)) then
    DoRegister(False);

  // ...and Action!
  OleCheck(PerfStartProviderEx(@FProviderGUID, nil, @FHandle));
  try

    for Category in FCategories do
      Category.Initialize;

  except
    // Cleanup so we leave the provider in a state where we can retry
    try

      StopProvider;

    except
      on E: Exception do
        Exception.RaiseOuterException(E);
    end;

    raise;
  end;

  FStarted := True;
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterProvider.StopProvider;
var
  Category: TPerformanceCounterCategory;
begin
  if (not FStarted) and (FHandle = 0) then
    exit;

  ASSERT(FHandle <> 0);

  for Category in FCategories do
    Category.Finalize;

  // Stop provider.
  try

    PerfStopProvider(FHandle);

  except
    // At this point we ignore errors. It is more important that we do not disrupt whatever shutdown sequence we're called from.
  end;

  FHandle := 0;
  FStarted := False;
end;


// -----------------------------------------------------------------------------

procedure TPerformanceCounterProvider.CheckNotStarted;
begin
  if (FStarted) then
    raise EPerfCountProvider.Create('Provider configuration can not be modified once started');
end;

procedure TPerformanceCounterProvider.CheckStarted;
begin
  if (not FStarted) then
    raise EPerfCountProvider.Create('Provider has not been started');
end;


// -----------------------------------------------------------------------------
//
//      TPerformanceCounterCategory
//
// -----------------------------------------------------------------------------
constructor TPerformanceCounterCategory.Create(AProvider: TPerformanceCounterProvider; const AName, ADescription: string; const AGUID: TGUID; AInstanceType: TPerformanceCounterInstanceType);
begin
  inherited Create;

  FProvider := AProvider;

  FInstances := TList<TPerformanceCounterInstance>.Create;
  FCounters := TPerformanceCounterCounterList.Create(Self);

  FName := AName;
  FDescription := ADescription;
  FCategoryGUID := AGUID;
  FInstanceType := AInstanceType;
end;

destructor TPerformanceCounterCategory.Destroy;
begin
  Finalize;

  FCounters.Free;
  FInstances.Free;

  inherited;
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterCategory.CreateCounterSetLayout;
var
  Counter: TPerformanceCounterCounter;
  i: integer;
  AttribValue: DWORD;
begin
  ASSERT(FCounterSetLayout = nil);

  FCounterSetLayoutSize := SizeOf(PERF_COUNTERSET_INFO) + FCounters.Count * SizeOf(PERF_COUNTER_INFO);

  FCounterSetLayout := AllocMem(FCounterSetLayoutSize); // AllocMem zeroes allocated memory

  FCounterSetLayout.Info.CounterSetGuid := FCategoryGUID;
  FCounterSetLayout.Info.ProviderGuid := FProvider.ProviderGUID;
  FCounterSetLayout.Info.NumCounters := FCounters.Count;
  FCounterSetLayout.Info.InstanceType := InstanceTypeMap[FInstanceType];

  i := 0;
  for Counter in FCounters do
  begin
{$IFOPT R+}
{$DEFINE R_PLUS}
{$RANGECHECKS OFF}
{$ENDIF}
    FCounterSetLayout.Counters[i].CounterId := i;
    FCounterSetLayout.Counters[i].CounterType := CounterTypeMap[Counter.CounterType];

    AttribValue := PERF_ATTRIB_BY_REFERENCE; // Counter value always by reference
    if (pcdoHide in Counter.DisplayOptions) then
      AttribValue := AttribValue or PERF_ATTRIB_NO_DISPLAYABLE;

    if (pcdoNoDigitSeparator in Counter.DisplayOptions) then
      AttribValue := AttribValue or PERF_ATTRIB_NO_GROUP_SEPARATOR;

    if (pcdoDisplayAsReal in Counter.DisplayOptions) then
      AttribValue := AttribValue or PERF_ATTRIB_DISPLAY_AS_REAL;

    if (pcdoDisplayAsHex in Counter.DisplayOptions) then
      AttribValue := AttribValue or PERF_ATTRIB_DISPLAY_AS_HEX;

    FCounterSetLayout.Counters[i].Attrib := AttribValue;
    FCounterSetLayout.Counters[i].DetailLevel := DetailLevelMap[Counter.DetailLevel];
    FCounterSetLayout.Counters[i].Scale := Counter.Scale;
    FCounterSetLayout.Counters[i].Offset := 0; // Value not used with PERF_ATTRIB_BY_REFERENCE
{$IFDEF R_PLUS}
{$RANGECHECKS ON}
{$UNDEF R_PLUS}
{$ENDIF}

    inc(i);
  end;
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterCategory.Validate(Start: boolean);
var
  Counter: TPerformanceCounterCounter;
begin
  // Perform preflight check
  if (Start) and (FCounters.Count = 0) then
    raise EPerfCountProvider.Create('Provider category requires at least one counter');

  for Counter in FCounters do
    Counter.Validate(Start);
end;

procedure TPerformanceCounterCategory.Initialize;
var
  Counter: TPerformanceCounterCounter;
begin
  ASSERT(Provider.Handle <> 0);

  CreateCounterSetLayout;

  // Configure the counter set
  OleCheck(PerfSetCounterSetInfo(Provider.Handle, PPERF_COUNTERSET_INFO(FCounterSetLayout), FCounterSetLayoutSize));

  // Initialize single instance
  if (not MultiInstance) then
  begin
    FSingleInstance := TPerformanceCounterInstance.Create;

    FInstances.Add(FSingleInstance);

    InitializeInstance(FSingleInstance, '', 0);
  end;

  for Counter in FCounters do
    Counter.Initialize;
end;

procedure TPerformanceCounterCategory.InitializeInstance(Instance: TPerformanceCounterInstance; const InstanceName: string; InstanceID: integer);
var
  Counter: TPerformanceCounterCounter;
begin
  Instance.Instance := PerfCreateInstance(Provider.Handle, @FCategoryGUID, PChar(InstanceName), InstanceID);
  if (Instance.Instance = nil) then
    RaiseLastOSError;

  SetLength(Instance.Values, FCounters.Count);

  for Counter in FCounters do
    Counter.InitializeInstance(Instance);
end;

procedure TPerformanceCounterCategory.Finalize;
var
  Instance: TPerformanceCounterInstance;
  Counter: TPerformanceCounterCounter;
begin
  FreeAndNil(FNamedInstances);
  FSingleInstance := nil;

  for Instance in FInstances do
  begin
    for Counter in FCounters do
      try
        Counter.FinalizeInstance(Instance);
      except
         // Ignore errors
      end;

    PerfDeleteInstance(Provider.Handle, Instance.Instance); // Ignore errors
  end;
  FInstances.Clear;
  FInstanceCounter := 0;

  for Counter in FCounters do
    try
      Counter.Finalize;
    except
       // Ignore errors
    end;

  if (FCounterSetLayout <> nil) then
  begin
    FreeMem(FCounterSetLayout);
    FCounterSetLayout := nil;
    FCounterSetLayoutSize := 0;
  end;
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterCategory.CheckMultiInstance;
begin
  if (not MultiInstance) then
    raise EPerfCountProvider.CreateFmt('Counter category "%s" does not support named instances', [Name]);
end;

procedure TPerformanceCounterCategory.CheckSingleInstance;
begin
  if (MultiInstance) then
    raise EPerfCountProvider.CreateFmt('Counter category "%s" requires an instance identification', [Name]);
end;

// -----------------------------------------------------------------------------

constructor TPerformanceCounterCategory.TPerformanceCounterCounterList.Create(ACategory: TPerformanceCounterCategory);
begin
  inherited Create;
  FCategory := ACategory;
end;

function TPerformanceCounterCategory.TPerformanceCounterCounterList.Add(ACounterType: TPerformanceCounterType): TPerformanceCounterCounter;
begin
  Result := Add(ACounterType, '', '');
end;

function TPerformanceCounterCategory.TPerformanceCounterCounterList.Add(ACounterType: TPerformanceCounterType; const AName, ADescription: string): TPerformanceCounterCounter;
var
  i: integer;
begin
  FCategory.Provider.CheckNotStarted;

  if (CounterTypeMap[ACounterType] and PERF_DISPLAY_NOSHOW = 0) then
  begin
    if (AName = '') then
      raise EPerfCountProvider.CreateFmt('The %s counter type requires a Name value', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(ACounterType))]);

    if (ADescription = '') then
      raise EPerfCountProvider.CreateFmt('The %s counter type requires a Description value', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(ACounterType))]);

    for i := 0 to Count-1 do
    begin
      if (Items[i].Name = AName) then
        raise EPerfCountProvider.CreateFmt('Duplicate counter name: %s', [AName]);
    end;
  end;

  Result := TPerformanceCounterCounter.Create(FCategory, Count, AName, ADescription, ACounterType);

  inherited Add(Result);
end;

// -----------------------------------------------------------------------------

function TPerformanceCounterCategory.GetNamedInstance(const InstanceName: string): TPerformanceCounterInstance;
begin
  CheckMultiInstance;
  Provider.CheckStarted;

  System.TMonitor.Enter(Self);
  try

    if (FNamedInstances = nil) then
      FNamedInstances := TDictionary<string, TPerformanceCounterInstance>.Create;

    if (not FNamedInstances.TryGetValue(InstanceName, Result)) then
    begin
      Result := TPerformanceCounterInstance.Create;

      FInstances.Add(Result);
      FNamedInstances.Add(InstanceName, Result);

      InitializeInstance(Result, InstanceName, FInstanceCounter);

      Inc(FInstanceCounter);
    end;

  finally
    System.TMonitor.Exit(Self);
  end;
end;

function TPerformanceCounterCategory.GetInstance(Index: integer): TPerformanceCounterInstance;
begin
  CheckMultiInstance;
  Provider.CheckStarted;

  System.TMonitor.Enter(Self);
  try

    Result := FInstances[Index];

  finally
    System.TMonitor.Exit(Self);
  end;
  ASSERT(PPERF_COUNTERSET_INSTANCE(Result.Instance).InstanceId = ULong(Index));
end;

// -----------------------------------------------------------------------------

function TPerformanceCounterCategory.GetInstanceCount: integer;
begin
  Provider.CheckStarted;

  Result := FInstanceCounter;
end;

// -----------------------------------------------------------------------------

function TPerformanceCounterCategory.GetMultiInstance: boolean;
begin
  Result := (FInstanceType in [pcitMultiInstance, pcitMultiAggregate]);
end;



// -----------------------------------------------------------------------------
//
//      TPerformanceCounterCounter
//
// -----------------------------------------------------------------------------
constructor TPerformanceCounterCounter.Create(ACategory: TPerformanceCounterCategory; ACounterID: integer; const AName, ADescription: string; ACounterType: TPerformanceCounterType);
begin
  inherited Create;

  FCategory := ACategory;

  FCounterID := ACounterID;
  FName := AName;
  FDescription := ADescription;
  FType := ACounterType;
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterCounter.Validate(Start: boolean);
begin
  // Perform preflight check

  if (MultiplierCounter = nil) and (CounterType in [pctCounterMultiTimer, pctCounterMultiTimerInv, pct100nsecMultiTimer, pct100nsecMultiTimerInv]) then
    raise EPerfCountProvider.CreateFmt('The %s counter type requires an assigned multiplier counter', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(CounterType))]);

  if (BaseCounter = nil) and (CounterType in [pctAverageTimer, pctAverageBulk, pctCounterMultiTimerInv, pctLargeRawFraction, pctPrecision100nsTimer, pctRawFraction, pctSampleFraction]) then
    raise EPerfCountProvider.CreateFmt('The %s counter type requires an assigned base counter', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(CounterType))]);

  if (CounterType in [pctCounterObjTimeQueuelenType, pctElapsedTime, pctObjTimeTimer, pctPrecisionObjectTimer]) then
  begin
    if (FrequencyCounter = nil) then
      raise EPerfCountProvider.CreateFmt('The %s counter type requires an assigned frequency counter', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(CounterType))]);

    if (TimeCounter = nil) then
      raise EPerfCountProvider.CreateFmt('The %s counter type requires an assigned time counter', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(CounterType))]);
  end;

end;

procedure TPerformanceCounterCounter.Initialize;
begin
end;

procedure TPerformanceCounterCounter.Finalize;
begin
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterCounter.InitializeInstance(Instance: TPerformanceCounterInstance);
begin
  Instance.Values[FCounterID] := 0;
  OleCheck(PerfSetCounterRefValue(Category.Provider.Handle, Instance.Instance, FCounterID, @Instance.Values[FCounterID]));
end;

procedure TPerformanceCounterCounter.FinalizeInstance(Instance: TPerformanceCounterInstance);
begin
  OleCheck(PerfSetCounterRefValue(Category.Provider.Handle, Instance.Instance, FCounterID, nil));
end;

// -----------------------------------------------------------------------------

function TPerformanceCounterCounter.GetDisplayOptions: TPerformanceCounterDisplayOptions;
begin
  Result := FDisplayOptions;

  if (CounterTypeMap[CounterType] and PERF_DISPLAY_NOSHOW <> 0) then
    Include(Result, pcdoHide);
end;

// -----------------------------------------------------------------------------

function TPerformanceCounterCounter.GetInstanceValue(Instance: TPerformanceCounterInstance): TPerformanceCounterValue;
begin
  Category.Provider.CheckStarted;
  Category.CheckMultiInstance;

  ASSERT(Instance <> nil);
  ASSERT(PPERF_COUNTERSET_INSTANCE(Instance.Instance).CounterSetGuid = Category.CategoryGUID);

  Result := @Instance.Values[CounterID];
end;

function TPerformanceCounterCounter.GetNamedInstanceValue(const Name: string): TPerformanceCounterValue;
var
  Instance: TPerformanceCounterInstance;
begin
  Instance := Category.Instances[Name];

  Result := GetInstanceValue(Instance);
end;

function TPerformanceCounterCounter.GetValue: TPerformanceCounterValue;
begin
  Category.Provider.CheckStarted;
  Category.CheckSingleInstance;


  Result := @Category.SingleInstance.Values[CounterID];
end;

// -----------------------------------------------------------------------------

function TPerformanceCounterCounter.GetIsHidden: boolean;
begin
  Result := (pcdoHide in DisplayOptions);
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterCounter.SetScale(const Value: integer);
begin
  if (Value < -10) or (Value > 10) then
    raise EPerfCountProvider.Create('Scale must be in the range -10 to 10');
  FScale := Value;
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterCounter.SetBaseCounter(const Value: TPerformanceCounterCounter);
var
  RequiredBaseType: TPerformanceCounterType;
begin
  Category.Provider.CheckNotStarted;

  if (Value <> nil) then
  begin
    if (Value.Category <> Category) then
      raise EPerfCountProvider.Create('Referenced counter must belong to the same counter set');

    case CounterType of
      pctAverageTimer:
        RequiredBaseType := pctAverageBase;
      pctAverageBulk:
        RequiredBaseType := pctAverageBulk;
      pctCounterMultiTimerInv:
        RequiredBaseType := pctCounterMultiBase;
      pctLargeRawFraction:
        RequiredBaseType := pctLargeRawBase;
      pctPrecision100nsTimer:
        RequiredBaseType := pctLargeRawBase;
      pctRawFraction:
        RequiredBaseType := pctRawBase;
      pctSampleFraction:
        RequiredBaseType := pctSampleBase;
    else
      raise EPerfCountProvider.CreateFmt('The %s counter type does not use a base counter', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(CounterType))]);
    end;

    if (RequiredBaseType <> Value.CounterType) then
      raise EPerfCountProvider.CreateFmt('The %s counter type requires a %s base counter', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(CounterType)), GetEnumName(TypeInfo(TPerformanceCounterType), Ord(RequiredBaseType))]);
  end;

  FBaseCounter := Value;
end;

procedure TPerformanceCounterCounter.SetFrequencyCounter(const Value: TPerformanceCounterCounter);
begin
  Category.Provider.CheckNotStarted;

  if (Value <> nil) then
  begin
    if (Value.Category <> Category) then
      raise EPerfCountProvider.Create('Referenced counter must belong to the same counter set');

    if (not(CounterType in [pctCounterObjTimeQueuelenType, pctElapsedTime, pctObjTimeTimer, pctPrecisionObjectTimer])) then
      raise EPerfCountProvider.CreateFmt('The %s counter type does not use a frequency counter', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(CounterType))]);

    if (Value.CounterType <> pctCounterLargeRawcount) then
      raise EPerfCountProvider.CreateFmt('The frequency counter must be of type %s', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(pctCounterLargeRawcount))]);
  end;

  FFrequencyCounter := Value;
end;

procedure TPerformanceCounterCounter.SetMultiplierCounter(const Value: TPerformanceCounterCounter);
begin
  Category.Provider.CheckNotStarted;

  if (Value <> nil) then
  begin
    if (Value.Category <> Category) then
      raise EPerfCountProvider.Create('Referenced counter must belong to the same counter set');

    if (not(CounterType in [pctCounterMultiTimer, pctCounterMultiTimerInv, pct100nsecMultiTimer, pct100nsecMultiTimerInv])) then
      raise EPerfCountProvider.CreateFmt('The %s counter type does not use a multiplier counter', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(CounterType))]);

//    if (Value.CounterType <> pctCounterRawcount) then
//      raise EPerfCountProvider.CreateFmt('The multiplier counter must be of type %s', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(pctCounterRawcount))]);
    if (Value.CounterType <> pctCounterMultiBase) then
      raise EPerfCountProvider.CreateFmt('The multiplier counter must be of type %s', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(pctCounterMultiBase))]);
  end;

  FMultiplierCounter := Value;
end;

procedure TPerformanceCounterCounter.SetTimeCounter(const Value: TPerformanceCounterCounter);
begin
  Category.Provider.CheckNotStarted;

  if (Value <> nil) then
  begin
    if (Value.Category <> Category) then
      raise EPerfCountProvider.Create('Referenced counter must belong to the same counter set');

    if (not(CounterType in [pctCounterObjTimeQueuelenType, pctElapsedTime, pctObjTimeTimer, pctPrecisionObjectTimer])) then
      raise EPerfCountProvider.CreateFmt('The %s counter type does not use a time counter', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(CounterType))]);

    if (Value.CounterType <> pctCounterLargeRawcount) then
      raise EPerfCountProvider.CreateFmt('The time counter must be of type %s', [GetEnumName(TypeInfo(TPerformanceCounterType), Ord(pctCounterLargeRawcount))]);
  end;


  FTimeCounter := Value;
end;


// -----------------------------------------------------------------------------
//
//      TPerformanceCounterValue
//
// -----------------------------------------------------------------------------
function TPerformanceCounterValueRec.GetValue: int64;
begin
  Result := TInterlocked.Read(FValue);
end;

procedure TPerformanceCounterValueRec.SetValue(const Value: int64);
begin
  TInterlocked.Exchange(FValue, Value);
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterValueRec.Decrement;
begin
  TInterlocked.Decrement(FValue);
end;

procedure TPerformanceCounterValueRec.Decrement(Delta: int64);
begin
  TInterlocked.Add(FValue, -Delta);
end;

// -----------------------------------------------------------------------------

procedure TPerformanceCounterValueRec.Increment;
begin
  TInterlocked.Increment(FValue);
end;

procedure TPerformanceCounterValueRec.Increment(Delta: int64);
begin
  TInterlocked.Add(FValue, Delta);
end;


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

var
  NeedCoUninitialize: boolean = False;
initialization
  // ShellExecute needs CoInitialize
  NeedCoUninitialize := Succeeded(CoInitializeEx(nil, COINIT_APARTMENTTHREADED or COINIT_DISABLE_OLE1DDE));
finalization
  if (NeedCoUninitialize) then
    CoUninitialize;
end.


