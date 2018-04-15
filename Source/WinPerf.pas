unit WinPerf;

//Translated from WINPERF.H
interface
uses
{$IFDEF WIN32}
  Windows;
{$ELSE}
  Wintypes, WinProcs;
{$ENDIF}


/// PERFLIB V2 provider side published literals, data structures and APIs.
const

  /// <summary>
  ///   This is used in generated <see cref="PERF_COUNTERSET_INFO" /> structure
  ///   to declare provider type
  /// </summary>
  PERF_PROVIDER_USER_MODE = 0;
  /// <summary>
  ///   This is used in generated <see cref="PERF_COUNTERSET_INFO" /> structure
  ///   to declare provider type
  /// </summary>
  /// <remarks>
  ///   Reserved for microsoft interal use
  /// </remarks>
  PERF_PROVIDER_KERNEL_MODE = 1;
  /// <summary>
  ///   This is used in generated PERF_COUNTERSET_INFO structure to declare
  ///   provider type
  /// </summary>
  PERF_PROVIDER_DRIVER = 2;

/// These are used for PERF_COUNTERSET_INFO::InstanceType value. That is, whether the CounterSet
/// allows multiple instances (for example, Process, PhysicalDisk, etc) or only single default instance
/// (for example, Memory, TCP, etc).
///
///


  /// <remarks>
  ///   used for PERF_COUNTERSET_INFO::InstanceType value
  /// </remarks>
  /// <seealso cref="PERF_COUNTERSET_INFO" />
  PERF_COUNTERSET_FLAG_MULTIPLE = 2; // 0010
  /// <summary>
  ///   only single default instance
  /// </summary>
  /// <remarks>
  ///   used for PERF_COUNTERSET_INFO::InstanceType value
  /// </remarks>
  /// <seealso cref="PERF_COUNTERSET_INFO" />
  PERF_COUNTERSET_FLAG_AGGREGATE = 4; // 0100
  /// <remarks>
  ///   used for PERF_COUNTERSET_INFO::InstanceType value
  /// </remarks>
  /// <seealso cref="PERF_COUNTERSET_INFO" />
  PERF_COUNTERSET_FLAG_HISTORY = 8; // 1000
  /// <remarks>
  ///   used for PERF_COUNTERSET_INFO::InstanceType value
  /// </remarks>
  /// <seealso cref="PERF_COUNTERSET_INFO" />
  PERF_COUNTERSET_FLAG_INSTANCE = 16; // 00010000
  /// <summary>
  ///   The counter set contains single instance counters, for example, a
  ///   counter that measures physical memory.
  /// </summary>
  /// <remarks>
  ///   used for PERF_COUNTERSET_INFO::InstanceType value
  /// </remarks>
  /// <seealso cref="PERF_COUNTERSET_INFO" />
  PERF_COUNTERSET_SINGLE_INSTANCE = 0;
  /// <summary>
  ///   The counter set contains multiple instance counters, for example, a
  ///   counter that measures the average bytes received per connection. <br />
  ///   corresponds to <c>single</c> in the xml manifest file
  /// </summary>
  /// <remarks>
  ///   used for <see href="PERF_COUNTERSET_INFO|InstanceType">
  ///   PERF_COUNTERSET_INFO.InstanceType</see> value
  /// </remarks>
  /// <seealso cref="PERF_COUNTERSET_INFO" />
  PERF_COUNTERSET_MULTI_INSTANCES = (PERF_COUNTERSET_FLAG_MULTIPLE);
  /// <summary>
  ///   The counter set contains single instance counters whose aggregate value
  ///   is obtained from one or more sources. For example, a counter in this
  ///   type of counter set might obtain the number of reads from each of the
  ///   three hard disks on the computer and sum their values. <br /><br />
  ///   corresponds to <c>globalAggregate</c> in the xml manifest file
  /// </summary>
  /// <remarks>
  ///   used for PERF_COUNTERSET_INFO::InstanceType value
  /// </remarks>
  /// <seealso cref="PERF_COUNTERSET_INFO" />
  PERF_COUNTERSET_SINGLE_AGGREGATE = (PERF_COUNTERSET_FLAG_AGGREGATE);
  /// <summary>
  ///   The counter set contains multiple instance counters whose aggregate
  ///   value is obtained from all instances of the counter. For example, a
  ///   counter in this type of counter set might obtain the total thread
  ///   execution time for all threads in a multi-threaded application and sum
  ///   their values.<br /><br />
  ///   corresponds to <c>multipleAggregate</c> in the xml manifest file
  /// </summary>
  /// <remarks>
  ///   used for PERF_COUNTERSET_INFO::InstanceType value
  /// </remarks>
  /// <seealso cref="PERF_COUNTERSET_INFO" />
  PERF_COUNTERSET_MULTI_AGGREGATE = (PERF_COUNTERSET_FLAG_AGGREGATE or PERF_COUNTERSET_FLAG_MULTIPLE);
  /// <summary>
  ///   The difference between this type and <b>
  ///   PERF_COUNTERSET_SINGLE_AGGREGATE</b> is that this counter set type
  ///   stores all counter values for the lifetime of the consumer application
  ///   (the counter value is cached beyond the lifetime of the counter). For
  ///   example, if one of the hard disks in the single aggregate example above
  ///   were to become unavailable, the total bytes read by that disk would
  ///   still be available and used to calculate the aggregate value.<br /><br />
  ///   corresponds to <c>globalAggregateHistory</c> in the xml manifest file
  /// </summary>
  /// <remarks>
  ///   used for PERF_COUNTERSET_INFO::InstanceType value
  /// </remarks>
  /// <seealso cref="PERF_COUNTERSET_INFO" />
  PERF_COUNTERSET_SINGLE_AGGREGATE_HISTORY = (PERF_COUNTERSET_FLAG_HISTORY or PERF_COUNTERSET_SINGLE_AGGREGATE);
  /// <summary>
  ///   This type is similar to <see cref="PERF_COUNTERSET_MULTI_AGGREGATE" />,
  ///   except that instead of aggregating all instance data to one aggregated
  ///   (_Total) instance, it will aggregate counter data from instances of the
  ///   same name. <br />For example, if multiple provider processes contained
  ///   instances named IExplore, <see cref="PERF_COUNTERSET_MULTIPLE" /> and <see cref="PERF_COUNTERSET_MULTI_AGGREGATE" />
  ///    CounterSet will show multiple IExplore instances (IExplore,
  ///   IExplore#1, IExplore#2, and so on); <br />however, a <see cref="PERF_COUNTERSET_INSTANCE_AGGREGATE" />
  ///    instance type will only publish one IExplore instance with aggregated
  ///   counter data from all instances named IExplore. <br /><br />
  ///   corresponds to <c>multipleAggregate</c> in the xml manifest file
  /// </summary>
  /// <remarks>
  ///   <para>
  ///     used for <see cref="PERF_COUNTERSET_INFO|InstanceType">
  ///     PERF_COUNTERSET_INFO.InstanceType</see> value
  ///   </para>
  ///   <para>
  ///     Windows Vista: This type is not available.
  ///   </para>
  /// </remarks>
  /// <seealso cref="PERF_COUNTERSET_INFO" />
  PERF_COUNTERSET_INSTANCE_AGGREGATE = (PERF_COUNTERSET_MULTI_AGGREGATE or PERF_COUNTERSET_FLAG_INSTANCE);


  /// <summary>
  ///   Pre-defined aggregation function for CounterSets that need counter data
  ///   aggregation
  /// </summary>
  /// <remarks>
  ///   This is only useful for CounterSet with instanceType: <br /><see cref="PERF_COUNTERSET_SINGLE_AGGREGATE" />
  ///   , <br /><see cref="PERF_COUNTERSET_MULTI_AGGREGATE" />, and <br /><see cref="PERF_COUNTERSET_SINGLE_AGGREGATE_HISTORY" />
  ///   . <br />For other CounterSet instanceTypes, this is no effect.
  /// </remarks>
  PERF_AGGREGATE_UNDEFINED = 0;
  PERF_AGGREGATE_TOTAL = 1;
  PERF_AGGREGATE_AVG = 2;
  PERF_AGGREGATE_MIN = 3;
  PERF_AGGREGATE_MAX = 4;

  /// <summary>
  ///   Retrieve the value of the counter by reference as opposed to by value
  /// </summary>
  /// <seealso cref="_PERF_COUNTER_INFO|Attrib" />
  PERF_ATTRIB_BY_REFERENCE = $0000000000000001;
  /// <summary>
  ///   Do not display the counter value
  /// </summary>
  PERF_ATTRIB_NO_DISPLAYABLE = $0000000000000002;
  /// <summary>
  ///   Do not use digit separators when displaying counter value
  /// </summary>
  PERF_ATTRIB_NO_GROUP_SEPARATOR = $0000000000000004;
  /// <summary>
  ///   Display the counter value as a real value
  /// </summary>
  PERF_ATTRIB_DISPLAY_AS_REAL = $0000000000000008;
  /// <summary>
  ///   Display the counter value as a hexadecimal number
  /// </summary>
  PERF_ATTRIB_DISPLAY_AS_HEX = $0000000000000010;

/// Provider counterset is defined as a leading PERF_COUNTERSET_INFO structure followed by a sequence
/// of PERF_COUNTER_INFO structures. Note that the structure block will be automatically generated
/// by schema generation/parsing tool.
type

  /// <summary>
  ///   Provider counterset is defined as a leading PERF_COUNTERSET_INFO
  ///   structure followed by a sequence of PERF_COUNTER_INFO structures. <br />
  ///   Note that the structure block will be automatically generated by schema
  ///   generation/parsing tool.
  /// </summary>
  PERF_COUNTERSET_INFO = record
    /// <summary>
    ///   GUID that uniquely identifies the counter set.
    /// </summary>
    /// <remarks>
    ///   The guid attribute of the counterSet element in the manifest contains
    ///   the GUID.
    /// </remarks>
    /// <example>
    ///   <c>CounterSetGuid: ( D1: $86792214; D2: $C435; D3: $4FB3; D4: ($9C,
    ///   $6D, $D7, $EC, $BF, $CB, $E9, $80));</c>
    /// </example>
    CounterSetGuid: TGUID;
    /// <summary>
    ///   GUID that uniquely identifies the provider that supports the counter
    ///   set.
    /// </summary>
    /// <remarks>
    ///   The providerGuid attribute of the provider element in the manifest
    ///   contains the GUID.
    /// </remarks>
    /// <example>
    ///   <c>ProviderGuid: ( D1: $0C8A39A9; D2: $F777; D3: $4687; D4: ($AE,
    ///   $E7, $5E, $BC, $8D, $7A, $3F, $23));</c>
    /// </example>
    ProviderGuid: TGUID;
    /// <summary>
    ///   Number of counters in the counter set. See remarks
    /// </summary>
    /// <remarks>
    ///   The memory block for this structure also contains one or more
    ///   PERF_COUNTER_INFO structures. The NumCounter member determines the
    ///   number of PERF_COUNTER_INFO structures that follow this structure in
    ///   memory
    /// </remarks>
    NumCounters: ULONG;
    /// <summary>
    ///   Specifies whether the counter set allows multiple instances
    /// </summary>
    /// <seealso cref="PERF_COUNTERSET_SINGLE_INSTANCE" />
    /// <seealso cref="PERF_COUNTERSET_MULTI_INSTANCES" />
    /// <seealso cref="PERF_COUNTERSET_SINGLE_AGGREGATE" />
    /// <seealso cref="PERF_COUNTERSET_MULTI_AGGREGATE" />
    /// <seealso cref="PERF_COUNTERSET_SINGLE_AGGREGATE_HISTORY" />
    /// <seealso cref="PERF_COUNTERSET_INSTANCE_AGGREGATE" />
    InstanceType: ULONG;
  end {_PERF_COUNTERSET_INFO};
  /// <seealso cref="_PERF_COUNTERSET_INFO" />
  PPERF_COUNTERSET_INFO = ^PERF_COUNTERSET_INFO;

  /// <summary>
  ///   Defines information about a counter that a provider uses.
  /// </summary>
  /// <remarks>
  ///   This structure is contained within a <see cref="PERF_COUNTERSET_INFO" />
  ///    or <see cref="PERF_COUNTERSET_INSTANCE" /> block
  /// </remarks>
  PERF_COUNTER_INFO = record
    /// <summary>
    ///   Identifier that uniquely identifies the counter within the counter
    ///   set
    /// </summary>
    CounterId: ULONG;
    {$REGION 'Documentation'}
    /// <summary>
    ///   <para>
    ///     Specifies the type of counter
    ///   </para>
    ///   <para>
    ///     coresponds to the following in the xml manifest: <br />
    ///   </para>
    ///   perf_counter_counter <br />perf_counter_timer <br />
    ///   perf_counter_queuelen_type <br />perf_counter_large_queuelen_type <br />
    ///   perf_counter_100ns_queuelen_type <br />
    ///   perf_counter_obj_time_queuelen_type <br />perf_counter_bulk_count <br />
    ///   perf_counter_text <br />perf_counter_rawcount <br />
    ///   perf_counter_large_rawcount <br />
    ///   perf_counter_rawcount_hexperf_counter_large_rawcount_hex <br />
    ///   perf_sample_fraction <br />perf_sample_counter <br />
    ///   perf_counter_timer_inv <br />perf_sample_base <br />
    ///   perf_average_timer <br />perf_average_base <br />perf_average_bulk <br />
    ///   perf_obj_time_timer <br />perf_100nsec_timer <br />
    ///   perf_100nsec_timer_inv <br />perf_counter_multi_timer <br />
    ///   perf_counter_multi_timer_inv <br />perf_counter_multi_base <br />
    ///   perf_100nsec_multi_timer <br />perf_100nsec_multi_timer_inv <br />
    ///   perf_raw_fraction <br />perf_large_raw_fraction <br />perf_raw_base <br />
    ///   perf_large_raw_base <br />perf_elapsed_time <br />perf_counter_delta <br />
    ///   perf_counter_large_delta <br />perf_precision_system_timer <br />
    ///   perf_precision_100ns_timer <br />perf_precision_object_timer <br />
    ///   perf_counter_composite
    /// </summary>
    {$ENDREGION}
    CounterType: ULONG;
    /// <summary>
    ///   One or more attributes that indicate how to display this counter
    /// </summary>
    /// <value>
    ///   <see cref="PERF_ATTRIB_BY_REFERENCE" /><br /><see cref="PERF_ATTRIB_NO_DISPLAYABLE" /><br /><see cref="PERF_ATTRIB_NO_GROUP_SEPARATOR" /><br /><see cref="PERF_ATTRIB_DISPLAY_AS_REAL" /><br /><see cref="PERF_ATTRIB_DISPLAY_AS_HEX" />
    /// </value>
    /// <remarks>
    ///   The attributes <see cref="PERF_ATTRIB_NO_GROUP_SEPARATOR" />, <see cref="PERF_ATTRIB_DISPLAY_AS_REAL" />
    ///   , and <see cref="PERF_ATTRIB_DISPLAY_AS_HEX" /> are not mutually
    ///   exclusive. If you specify all three attributes, precedence is given
    ///   to the attributes in the order given
    /// </remarks>
    Attrib: ULONGLONG;
    /// <summary>
    ///   Size, in bytes, of this structure
    /// </summary>
    Size: ULONG;
    /// <summary>
    ///   Specify the target audience for the counter
    /// </summary>
    /// <value>
    ///   <para>
    ///     <see cref="PERF_DETAIL_NOVICE" />
    ///   </para>
    ///   <para>
    ///     <see cref="PERF_DETAIL_ADVANCED" />
    ///   </para>
    /// </value>
    DetailLevel: ULONG;
    /// <summary>
    ///   Scale factor to apply to the counter value. Valid values range from
    ///   –10 through 10. Zero if no scale is applied. If this value is zero,
    ///   the scale value is 1; if this value is 1, the scale value is 10; if
    ///   this value is –1, the scale value is .10; and so on
    /// </summary>
    Scale: LongInt;
    /// <summary>
    ///   Byte offset from the beginning of the <see cref="PERF_COUNTERSET_INSTANCE" />
    ///    block to the counter value
    /// </summary>
    Offset: ULONG;
  end {_PERF_COUNTER_INFO};
  PPERF_COUNTER_INFO = ^PERF_COUNTER_INFO;




  /// <summary>
  ///   Defines an instance of a counter set. <br />
  /// </summary>
  /// <remarks>
  ///   PERF_COUNTERSET_INSTANCE block is returned from <see cref="PerfCreateInstance" />
  ///    API call to identify specific instance of a counterset. <br />The
  ///   returned block is formed by PERF_COUNTERSET_INSTANCE structure followed
  ///   by counter data block (layout defined by provider counterset template)
  ///   and instance name string (if exists).
  /// </remarks>
  PERF_COUNTERSET_INSTANCE = record
    /// <summary>
    ///   GUID that identifies the counter set to which this instance belongs
    /// </summary>
    CounterSetGuid: TGUID;
    /// <summary>
    ///   Size, in bytes, of the instance block. The instance block contains
    ///   this structure, followed by one or more <see cref="PERF_COUNTER_INFO" />
    ///    blocks, and ends with the instance name
    /// </summary>
    dwSize: ULONG;
    /// <summary>
    ///   Identifier that uniquely identifies this instance.
    /// </summary>
    /// <remarks>
    ///   The provider specified the identifier when calling <see cref="PerfCreateInstance" />
    /// </remarks>
    InstanceId: ULONG;
    /// <summary>
    ///   Byte offset from the beginning of this structure to the
    ///   null-terminated Unicode instance name. <br />
    /// </summary>
    /// <remarks>
    ///   The provider specified the instance name when calling <see cref="PerfCreateInstance" />
    /// </remarks>
    InstanceNameOffset: ULONG;
    /// <summary>
    ///   Size, in bytes, of the instance name. The size includes the
    ///   null-terminator
    /// </summary>
    InstanceNameSize: ULONG;
  end {_PERF_COUNTERSET_INSTANCE};
  PPERF_COUNTERSET_INSTANCE = ^PERF_COUNTERSET_INSTANCE;

  /// <summary>
  ///   Defines the counter that is sent to a provider's callback when the
  ///   consumer adds or removes a counter from the query
  /// </summary>
  /// <remarks>
  ///   PERF_COUNTER_IDENTITY structure is used in customized notification
  ///   callback. Wheneven PERFLIB V2 <br />invokes customized notification
  ///   callback, it passes wnode datablock (which contains WNODE_HEADER <br />
  ///   structure followed by other binary data) that contains the information
  ///   providers can use. <br /><br />For PERF_ADD_COUNTER and
  ///   PERF_REMOVE_COUNTER request, PERFLIB will pass PERF_COUNTER_IDENTITY
  ///   block <br />so that providers know which counter is added/removed. For
  ///   other requests, currently only machine name <br />is passed (so that
  ///   providers can determine whether the request is for physical node or
  ///   virtual node).
  /// </remarks>
  PERF_COUNTER_IDENTITY = record
    /// <summary>
    ///   GUID that uniquely identifies the counter set that this counter
    ///   belongs to
    /// </summary>
    CounterSetGuid: TGUID;
    /// <summary>
    ///   Size, in bytes, of this structure and the computer name and instance
    ///   name that are appended to this structure in memory
    /// </summary>
    BufferSize: ULONG;
    /// <summary>
    ///   Unique identifier of the counter in the counter set
    /// </summary>
    /// <remarks>
    ///   This member is set to PERF_WILDCARD_COUNTER if the consumer wants to
    ///   add or remove all counters in the counter set
    /// </remarks>
    CounterId: ULONG;
    /// <summary>
    ///   Identifier of the counter set instance to which the counter belongs
    /// </summary>
    /// <remarks>
    ///   Ignore this value if the instance name at NameOffset is
    ///   PERF_WILDCARD_INSTANCE
    /// </remarks>
    InstanceId: ULONG;
    /// <summary>
    ///   Offset to the null-terminated Unicode computer name that follows this
    ///   structure in memory
    /// </summary>
    MachineOffset: ULONG;
    /// <summary>
    ///   Offset to the null-terminated Unicode instance name that follows this
    ///   structure in memory
    /// </summary>
    NameOffset: ULONG;
    /// <summary>
    ///   Reserved
    /// </summary>
    Reserved: ULONG;
  end {_PERF_COUNTER_IDENTITY};
  PPERF_COUNTER_IDENTITY = ^PERF_COUNTER_IDENTITY;

const
  PERF_WILDCARD_COUNTER = $FFFFFFF;
  PERF_WILDCARD_INSTANCE = '*';
  PERF_AGGREGATE_INSTANCE = '_Total';
  PERF_MAX_INSTANCE_NAME = 1024;

  PERF_ADD_COUNTER = 1;
  PERF_REMOVE_COUNTER = 2;
  PERF_ENUM_INSTANCES = 3;
  PERF_COLLECT_START = 5;
  PERF_COLLECT_END = 6;
  PERF_FILTER = 9;

/// Prototype for service request callback. Data providers register with PERFLIB V2 by passing a service
/// request callback function that is called for all PERFLIB requests.
type PERFLIBREQUEST = function (RequestCode: LongWord;
                                Buffer:  Pointer;
                                BufferSize:  LongWord): ULONG  cdecl  stdcall;

/// Usually PerfSetCounterSetInfo() calls is automatically generated PerfAutoStartUp() function (generated
/// by schema generation/parsing tool) to inform PERFLIB the layout of specific counterset.
///
function PerfStartProvider(ProviderGuid: PGUID;
                           ControlCallback: PERFLIBREQUEST;
                           phProvider:  PHANDLE): ULONG cdecl  stdcall;  external 'Advapi32.DLL';

/// Start PERFLIB V2 provider with customized memory allocation/free routines.
///
type
  PERF_MEM_ALLOC = function(ALLOCSIZE:SIZE_T; PCONTEXT: Pointer):Pointer;
type
  PERF_MEM_FREE = procedure(PBUFFER: Pointer; PCONTEXT: Pointer);

type
  _PROVIDER_CONTEXT = record
    ContextSize: LongInt;
    Reserved: LongInt;
    ControlCallback: PERFLIBREQUEST;
    MemAllocRoutine: PERF_MEM_ALLOC;
    MemFreeRoutine: PERF_MEM_FREE;
    pMemContext: PVOID;
  end {_PROVIDER_CONTEXT};
  PERF_PROVIDER_CONTEXT = _PROVIDER_CONTEXT;
  PPERF_PROVIDER_CONTEXT = ^_PROVIDER_CONTEXT;


//  ULONG WINAPI
function PerfStartProviderEx(ProviderGuid: PGUID;
                             ProviderContext: PPERF_PROVIDER_CONTEXT;
                             Provider: PHANDLE
                             ): ULONG stdcall ; external 'Advapi32.DLL';


function PerfStopProvider(ProviderHandle: THANDLE): ULONG stdcall ; external 'Advapi32.DLL';


function PerfSetCounterSetInfo(ProviderHandle: THANDLE;
                               Template: PPERF_COUNTERSET_INFO;
                               TemplateSize:  ULONG): ULONG stdcall ;  external 'Advapi32.DLL';


function PerfCreateInstance(ProviderHandle: THANDLE;
                            CounterSetGuid: PGUID;
                            Name:  PWideChar;
                            Id: ULONG): PPERF_COUNTERSET_INSTANCE stdcall ;  external 'Advapi32.DLL';


function PerfDeleteInstance(Provider: THANDLE;
                            InstanceBlock: PPERF_COUNTERSET_INSTANCE): ULONG stdcall ;  external 'Advapi32.DLL';


function PerfQueryInstance(ProviderHandle: THANDLE;
                           CounterSetGuid: PGUID;
                           Name: PWideChar;
                           Id: ULONG): PERF_COUNTERSET_INSTANCE stdcall;  external 'Advapi32.DLL';


function PerfSetCounterRefValue(Provider: THANDLE;
                                Instance: PPERF_COUNTERSET_INSTANCE;
                                CounterId: ULONG;
                                Address: PVOID): ULONG stdcall;  external 'Advapi32.DLL';


function PerfSetULongCounterValue(Provider: THANDLE;
                                  Instance: PPERF_COUNTERSET_INSTANCE;
                                  CounterId: ULONG;
                                  Value: ULONG): ULONG stdcall ; external 'Advapi32.DLL';


function PerfSetULongLongCounterValue(Provider: THANDLE;
                                      Instance: PPERF_COUNTERSET_INSTANCE;
                                      CounterId: ULONG;
                                      Value: ULONGLONG): ULONG stdcall; external 'Advapi32.DLL';


function PerfIncrementULongCounterValue(Provider: THANDLE;
                                        Instance: PPERF_COUNTERSET_INSTANCE;
                                        CounterId: ULONG;
                                        Value: ULONG): ULONG stdcall;  external 'Advapi32.DLL';


function PerfIncrementULongLongCounterValue(Provider: THANDLE;
                                            Instance: PPERF_COUNTERSET_INSTANCE;
                                            CounterId: ULONG;
                                            Value: ULONGLONG): ULONG stdcall; external 'Advapi32.DLL';


function PerfDecrementULongCounterValue(Provider: THANDLE;
                                        Instance: PPERF_COUNTERSET_INSTANCE;
                                        CounterId: ULONG;
                                        Value: ULONG): ULONG stdcall; external 'Advapi32.DLL';


function PerfDecrementULongLongCounterValue(Provider: THANDLE;
                                            Instance: PPERF_COUNTERSET_INSTANCE;
                                            CounterId: ULONG;
                                            Value: ULONGLONG): ULONG stdcall; external 'Advapi32.DLL';

implementation
end.
