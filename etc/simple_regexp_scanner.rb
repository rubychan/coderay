# SimpleRegexpScanner is a scanner for simple regular expressions.
# 
# Written by murphy (Kornelius Kalnbach), September 2008.
# 
# Released under LGPL, see http://www.gnu.org/licenses/lgpl.html.

require 'strscan'

# A very simple scanner that can parse a subset of regular expressions. It can parse:
# - Literals: A (including empty words)
# - Groups: (A)
# - Concatenations: AB
# - Alternatives: A|B
# - Options: (A)? (for groups only!)
# 
# Usage:
#  srs = SimpleRegexpScanner.new('(A)?(B|C)')
#  p srs.list  #=> ['AB', 'AC', 'B', 'C']
class SimpleRegexpScanner < StringScanner
  
  # Returns an Array of all possible strings that would fit the given regexp.
  def list
    scan_union.uniq
  end
  
protected
  def scan_group  # :nodoc:
    scan(/\(/) or return
    options = scan_union
    scan(/\)/) or raise ') expected at end of group'
    options << '' if scan(/\?/)
    options
  end
  
  def scan_union  # :nodoc:
    options = scan_concatenation
    options += scan_union if scan(/\|/)
    options.uniq
  end
  
  def scan_concatenation  # :nodoc:
    options = scan_group || [scan(/[^(|)?]*/)]
    if check(/[^|)]/)
      suffixes = scan_concatenation
      options.map! do |option|
        suffixes.map { |suffix| option + suffix }
      end.flatten!
    end
    options
  end
  
end

if $0 == __FILE__
  $VERBOSE = true
  eval DATA.read, nil, $0, __LINE__ + 4
end

__END__
require 'test/unit'

class SimpleRegexpScannerTest < Test::Unit::TestCase
  
  def assert_scans_list regexp, list
    assert_equal list, SimpleRegexpScanner.new(regexp).list
  end
  
  def assert_scans_list_size regexp, size
    assert_equal size, SimpleRegexpScanner.new(regexp).list.size
  end
  
  def test_simple
    assert_scans_list '', ['']
    assert_scans_list '()', ['']
    assert_scans_list '|', ['']
    assert_scans_list 'A', ['A']
    assert_scans_list 'A|B', ['A', 'B']
    assert_scans_list '(A)', ['A']
    assert_scans_list '(A)B', ['AB']
    assert_scans_list 'A(B)', ['AB']
  end
  
  def test_complex
    assert_scans_list 'A|', ['A', '']
    assert_scans_list '|A', ['', 'A']
    assert_scans_list '(((|(((|))))|)|)', ['']
    assert_scans_list '(A|B)', ['A', 'B']
    assert_scans_list '(A)?', ['A', '']
    assert_scans_list '(A|B)?', ['A', 'B', '']
    assert_scans_list 'A(B)?', ['AB', 'A']
    assert_scans_list '(A(B(C|D))?)?', ['ABC', 'ABD', 'A', '']
  end
  
  JAVA_BUILTIN_TYPES = <<-TYPES.delete(" \n")
    (R(GBImageFilter|MI(S(ocketFactory|e(curity(Manager|Exception)|rver(SocketFactor
    y|Impl(_Stub)?)?))|C(onnect(ion(Impl(_Stub)?)?|or(Server)?)|l(ientSocketFactory|
    assLoader(Spi)?))|IIOPServerImpl|JRMPServerImpl|FailureHandler)|SA(MultiPrimePri
    vateCrtKey(Spec)?|OtherPrimeInfo|P(ublicKey(Spec)?|rivate(CrtKey(Spec)?|Key(Spec
    )?))|Key(GenParameterSpec)?)|o(otPane(Container|UI)|und(Rectangle2D|ingMode)|w(M
    apper|Set(Reader|MetaData(Impl)?|Internal|Event|W(arning|riter)|Listener)?)|le(R
    esult|Status|NotFoundException|Info(NotFoundException)?|Unresolved(List)?|List)?
    |bot)|dn|C(2ParameterSpec|5ParameterSpec)|u(n(nable|time(M(XBean|BeanException)|
    OperationsException|Permission|E(rrorException|xception))?)|leBasedCollator)|TFE
    ditorKit|e(s(caleOp|o(urceBundle|l(utionSyntax|ve(Result|r)))|ult(Set(MetaData)?
    )?|ponseCache)|nder(ingHints|Context|e(dImage(Factory)?|r)|ableImage(Op|Producer
    )?)|c(tang(ularShape|le(2D)?)|eiver)|tention(Policy)?|jectedExecution(Handler|Ex
    ception)|p(licateScaleFilter|aintManager)|entrant(ReadWriteLock|Lock)|verbType|q
    u(iredModelMBean|estingUserName)|f(er(ence(UriSchemesSupported|able|Queue)?|ralE
    xception)|lect(ionException|Permission)|resh(able|FailedException)|Addr)?|lation
    (S(upport(MBean)?|ervice(MBean|NotRegisteredException)?)|Not(ification|FoundExce
    ption)|Type(Support|NotFoundException)?|Exception)?|a(d(er|OnlyBufferException|a
    ble(ByteChannel)?|WriteLock)|lmC(hoiceCallback|allback))|gi(st(erableService|ry(
    Handler)?)|on)|mote(Ref|S(tub|erver)|Call|Object(InvocationHandler)?|Exception)?
    )|a(ster(Op|FormatException)?|ndom(Access(File)?)?))|G(uard(edObject)?|ener(ic(S
    ignatureFormatError|Declaration|ArrayType)|al(SecurityException|Path))|ZIP(Input
    Stream|OutputStream)|lyph(Metrics|JustificationInfo|V(iew|ector))|a(theringByteC
    hannel|ugeMonitor(MBean)?|pContent|rbageCollectorMXBean)|r(id(Bag(Constraints|La
    yout)|Layout)|oup|egorianCalendar|a(yFilter|dientPaint|phic(s(2D|Config(uration|
    Template)|Device|Environment)?|Attribute))))|X(ML(GregorianCalendar|Constants|De
    coder|ParseException|Encoder|Formatter)|id|Path(Constants|Ex(ception|pression(Ex
    ception)?)|VariableResolver|F(unction(Resolver|Exception)?|actory(ConfigurationE
    xception)?))?|50(9(C(RL(Selector|Entry)?|ert(ificate|Selector))|TrustManager|E(n
    codedKeySpec|xten(sion|dedKeyManager))|KeyManager)|0Pri(ncipal|vateCredential))|
    ml(Reader|Writer)|A(Resource|Connection|DataSource|Exception))|M(GF1ParameterSpe
    c|Bean(Registration(Exception)?|Server(Builder|Notification(Filter)?|Connection|
    InvocationHandler|Delegate(MBean)?|Permission|F(orwarder|actory))?|NotificationI
    nfo|ConstructorInfo|TrustPermission|Info|OperationInfo|P(ermission|arameterInfo)
    |Exception|FeatureInfo|AttributeInfo)|i(ssing(ResourceException|Format(WidthExce
    ption|ArgumentException))|nimalHTMLWriter|di(Message|System|Channel|Device(Provi
    der)?|UnavailableException|Event|File(Reader|Format|Writer))|xer(Provider)?|meTy
    peParseException)|o(nitor(MBean|SettingException|Notification)?|d(ifi(cationItem
    |er)|elMBean(Notification(Broadcaster|Info)|ConstructorInfo|Info(Support)?|Opera
    tionInfo|AttributeInfo)?)|use(Motion(Listener|Adapter)|In(put(Listener|Adapter)|
    fo)|DragGestureRecognizer|Event|Wheel(Event|Listener)|Listener|Adapter))|u(table
    (ComboBoxModel|TreeNode|AttributeSet)|lti(RootPaneUI|castSocket|Menu(BarUI|ItemU
    I)|ButtonUI|S(croll(BarUI|PaneUI)|p(innerUI|litPaneUI)|eparatorUI|liderUI)|Co(lo
    rChooserUI|mboBoxUI)|T(ool(BarUI|TipUI)|extUI|ab(le(HeaderUI|UI)|bedPaneUI)|reeU
    I)|InternalFrameUI|ple(Master|DocumentHandling)|OptionPaneUI|D(oc(Print(Service|
    Job))?|esktop(IconUI|PaneUI))|P(ixelPackedSampleModel|opupMenuUI|anelUI|rogressB
    arUI)|ViewportUI|FileChooserUI|L(istUI|ookAndFeel|abelUI)))|e(ssage(Digest(Spi)?
    |Format)|nu(Bar(UI)?|S(hortcut|electionManager)|Co(ntainer|mponent)|Item(UI)?|Dr
    agMouse(Event|Listener)|E(vent|lement)|Key(Event|Listener)|Listener)?|t(hod(Desc
    riptor)?|a(Message|EventListener|l(R(ootPaneUI|adioButtonUI)|MenuBarUI|B(orders|
    uttonUI)|S(croll(B(utton|arUI)|PaneUI)|plitPaneUI|eparatorUI|liderUI)|C(heckBox(
    Icon|UI)|omboBox(Button|Icon|UI|Editor))|T(heme|o(ol(BarUI|TipUI)|ggleButtonUI)|
    extFieldUI|abbedPaneUI|reeUI)|I(nternalFrame(TitlePane|UI)|conFactory)|DesktopIc
    onUI|P(opupMenuSeparatorUI|rogressBarUI)|FileChooserUI|L(ookAndFeel|abelUI))))|d
    ia(Size(Name)?|Name|Tra(y|cker)|PrintableArea)?|m(ory(M(XBean|anagerMXBean)|Hand
    ler|NotificationInfo|CacheImage(InputStream|OutputStream)|Type|ImageSource|Usage
    |PoolMXBean)|ber))|a(skFormatter|n(ifest|age(ReferralControl|rFactoryParameters|
    ment(Permission|Factory)))|c(Spi)?|t(h(Context)?|ch(Result|er)|teBorder)|p(pedBy
    teBuffer)?|lformed(InputException|ObjectNameException|URLException|Parameterized
    TypeException|LinkException)|rshal(Exception|ledObject))|Let(MBean)?)|B(yte(Buff
    er|Channel|Order|LookupTable|Array(InputStream|OutputStream))?|MPImageWriteParam
    |i(n(d(ing|Exception)|aryRefAddr)|tSet|di|g(Integer|Decimal))|o(o(k|lean(Control
    )?)|undedRangeModel|rder(UIResource|Factory|Layout)?|x(View|Layout)?)|u(tton(Gro
    up|Model|UI)?|ffer(Strategy|Capabilities|ed(Reader|I(nputStream|mage(Op|Filter)?
    )|OutputStream|Writer)|OverflowException|UnderflowException)?)|e(velBorder|an(s|
    Context(Membership(Event|Listener)|S(upport|ervice(s(Support|Listener)?|Revoked(
    Event|Listener)|Provider(BeanInfo)?|AvailableEvent))|C(hild(Support|ComponentPro
    xy)?|ontainerProxy)|Proxy|Event)?|Info|Descriptor))|lo(ck(ingQueue|View)|b)|a(s(
    ic(R(ootPaneUI|adioButton(MenuItemUI|UI))|GraphicsUtils|Menu(BarUI|ItemUI|UI)|B(
    orders|utton(UI|Listener))|S(croll(BarUI|PaneUI)|troke|p(innerUI|litPane(Divider
    |UI))|eparatorUI|liderUI)|HTML|C(heckBox(MenuItemUI|UI)|o(ntrol|lorChooserUI|mbo
    (Box(Renderer|UI|Editor)|Popup)))|T(o(ol(Bar(SeparatorUI|UI)|TipUI)|ggleButtonUI
    )|ext(UI|PaneUI|FieldUI|AreaUI)|ab(le(HeaderUI|UI)|bedPaneUI)|reeUI)|I(nternalFr
    ame(TitlePane|UI)|conFactory)|OptionPaneUI|D(irectoryModel|esktop(IconUI|PaneUI)
    )|P(opupMenu(SeparatorUI|UI)|ermission|a(sswordFieldUI|nelUI)|rogressBarUI)|Edit
    orPaneUI|ViewportUI|F(ileChooserUI|ormattedTextFieldUI)|L(istUI|ookAndFeel|abelU
    I)|A(ttribute(s)?|rrowButton))|eRowSet)|nd(CombineOp|edSampleModel)|ckingStoreEx
    ception|tchUpdateException|d(BinaryOpValueExpException|StringOperationException|
    PaddingException|LocationException|AttributeValueExpException))|r(okenBarrierExc
    eption|eakIterator))|S(slRMI(ServerSocketFactory|ClientSocketFactory)|h(ort(Mess
    age|Buffer(Exception)?|LookupTable)?|eetCollate|ape(GraphicAttribute)?)|y(s(tem(
    Color|FlavorMap)?|exMessage)|n(c(hronousQueue|Resolver|Provider(Exception)?|Fa(c
    tory(Exception)?|iledException))|th(GraphicsUtils|Style(Factory)?|Con(stants|tex
    t)|esizer|Painter|LookAndFeel)))|c(he(duled(ThreadPoolExecutor|ExecutorService|F
    uture)|ma(ViolationException|Factory(Loader)?)?)|a(nner|tteringByteChannel)|roll
    (BarUI|Pane(Constants|UI|Layout|Adjustable)?|able|bar))|t(yle(Sheet|d(Document|E
    ditorKit)|Con(stants|text))?|ub(NotFoundException|Delegate)?|a(ndardMBean|ck(Tra
    ceElement|OverflowError)?|te(Edit(able)?|Factory|ment)|rtTlsRe(sponse|quest))|r(
    i(ng(Re(fAddr|ader)|Monitor(MBean)?|Bu(ilder|ffer(InputStream)?)|Selection|C(har
    acterIterator|ontent)|Tokenizer|IndexOutOfBoundsException|ValueExp|Writer)?|ctMa
    th)|oke|uct|eam(Result|Source|Handler|CorruptedException|Tokenizer|PrintService(
    Factory)?)))|i(ngle(SelectionModel|PixelPackedSampleModel)|ze(Requirements|Seque
    nce|2DSyntax|LimitExceededException)|des|gn(e(dObject|r)|ature(Spi|Exception)?)|
    mple(BeanInfo|T(ype|imeZone)|D(oc|ateFormat)|Formatter|AttributeSet))|SL(S(ocket
    (Factory)?|e(ssion(Binding(Event|Listener)|Context)?|rverSocket(Factory)?))|Hand
    shakeException|Context(Spi)?|P(e(erUnverifiedException|rmission)|rotocolExceptio
    n)|E(ngine(Result)?|xception)|KeyException)|o(cket(SecurityException|Handler|Cha
    nnel|TimeoutException|Impl(Factory)?|Options|Permission|Exception|Factory|Addres
    s)?|u(ndbank(Re(source|ader))?|rce(DataLine|Locator)?)|ft(Reference|BevelBorder)
    |rt(ResponseControl|ingFocusTraversalPolicy|Control|ed(Map|Set)|Key))|u(pp(orted
    ValuesAttribute|ressWarnings)|bject(D(omainCombiner|elegationPermission))?)|p(in
    ner(Model|NumberModel|DateModel|UI|ListModel)|litPaneUI|ring(Layout)?)|e(c(ur(it
    y(Manager|Permission|Exception)?|e(Random(Spi)?|C(lassLoader|acheResponse)))|ret
    Key(Spec|Factory(Spi)?)?)|t(OfIntegerSyntax)?|paratorUI|verity|quence(InputStrea
    m|r)?|lect(ionKey|or(Provider)?|ableChannel)|a(ledObject|rch(Result|Controls))|r
    (ial(Ref|Blob|izable(Permission)?|Struct|Clob|Datalink|JavaObject|Exception|Arra
    y)|v(ice(Registry|NotFoundException|U(navailableException|I(Factory)?)|Permissio
    n)|er(R(untimeException|ef)|Socket(Channel|Factory)?|NotActiveException|CloneExc
    eption|E(rror|xception))))|gment|maphore)|keleton(MismatchException|NotFoundExce
    ption)?|wing(Constants|Utilities|PropertyChangeSupport)|liderUI|a(sl(Server(Fact
    ory)?|Client(Factory)?|Exception)?|vepoint|mpleModel)|QL(Input(Impl)?|Output(Imp
    l)?|Data|Permission|Exception|Warning)|AX(Result|Source|TransformerFactory|Parse
    r(Factory)?))|H(yperlink(Event|Listener)|ttp(sURLConnection|RetryException|URLCo
    nnection)|i(erarchy(Bounds(Listener|Adapter)|Event|Listener)|ghlighter)|ostnameV
    erifier|TML(Document|EditorKit|FrameHyperlinkEvent|Writer)?|eadlessException|a(s
    (h(Map|table|Set|DocAttributeSet|Print(RequestAttributeSet|ServiceAttributeSet|J
    obAttributeSet)|AttributeSet)|Controls)|nd(shakeCompleted(Event|Listener)|ler)))
    |N(o(RouteToHostException|n(ReadableChannelException|invertibleTransformExceptio
    n|WritableChannelException)|t(BoundException|ification(Result|Broadcaster(Suppor
    t)?|Emitter|Filter(Support)?|Listener)?|SerializableException|Yet(BoundException
    |ConnectedException)|Co(ntextException|mpliantMBeanException)|OwnerException|Act
    iveException)|Such(MethodE(rror|xception)|ObjectException|P(addingException|rovi
    derException)|ElementException|FieldE(rror|xception)|A(ttributeException|lgorith
    mException))|deChange(Event|Listener)|C(onnectionPendingException|lassDefFoundEr
    ror)|InitialContextException|PermissionException)|u(ll(Cipher|PointerException)|
    m(ericShaper|ber(Of(InterveningJobs|Documents)|Up(Supported)?|Format(ter|Excepti
    on)?)?))|e(t(Permission|workInterface)|gativeArraySizeException)|a(vigationFilte
    r|m(ing(Manager|SecurityException|E(numeration|vent|xception(Event)?)|Listener)?
    |e(spaceC(hangeListener|ontext)|NotFoundException|C(lassPair|allback)|Parser|Alr
    eadyBoundException)?)))|C(h(oice(Callback|Format)?|eck(sum|ed(InputStream|Output
    Stream)|box(Group|MenuItem)?)|a(n(nel(s)?|ge(dCharSetException|Event|Listener))|
    r(set(Decoder|Provider|Encoder)?|Buffer|Sequence|ConversionException|acter(Codin
    gException|Iterator)?|Array(Reader|Writer)))|romaticity)|R(C32|L(Selector|Except
    ion)?)|yclicBarrier|MMException|ipher(Spi|InputStream|OutputStream)?|SS|o(n(s(tr
    uctor|oleHandler)|nect(ion(P(oolDataSource|endingException)|Event(Listener)?)?|I
    OException|Exception)|current(M(odificationException|ap)|HashMap|LinkedQueue)|t(
    e(nt(Model|Handler(Factory)?)|xt(NotEmptyException|ualRenderedImageFactory)?)|ai
    ner(OrderFocusTraversalPolicy|Event|Listener|Adapter)?|rol(lerEventListener|Fact
    ory)?)|dition|volveOp|fi(rmationCallback|guration(Exception)?))|okieHandler|d(in
    gErrorAction|e(S(igner|ource)|r(Result|MalfunctionError)))|unt(erMonitor(MBean)?
    |DownLatch)|p(yOnWriteArray(Set|List)|ies(Supported)?)|l(or(Model|S(upported|pac
    e|electionModel)|C(hooser(ComponentFactory|UI)|onvertOp)|Type|UIResource)?|l(ect
    ion(s|CertStoreParameters)?|at(ion(ElementIterator|Key)|or)))|m(p(il(er|ationMXB
    ean)|o(site(Name|Context|Type|Data(Support)?|View)?|nent(SampleModel|ColorModel|
    InputMap(UIResource)?|Orientation|UI|Event|View|Listener|Adapter)?|und(Border|Na
    me|Control|Edit))|letionService|ara(tor|ble)|ression)|municationException|bo(Box
    (Model|UI|Editor)|Popup)))|u(stomizer|r(sor|rency)|bicCurve2D)|e(ll(RendererPane
    |Editor(Listener)?)|rt(ificate(NotYetValidException|ParsingException|E(ncodingEx
    ception|x(ception|piredException))|Factory(Spi)?)?|S(tore(Spi|Parameters|Excepti
    on)?|elector)|Path(Builder(Result|Spi|Exception)?|TrustManagerParameters|Paramet
    ers|Validator(Result|Spi|Exception)?)?))|l(ip(board(Owner)?)?|o(se(d(ByInterrupt
    Exception|SelectorException|ChannelException)|able)|ne(NotSupportedException|abl
    e)|b)|ass(NotFoundException|C(ircularityError|astException)|De(sc|finition)|F(il
    eTransformer|ormatError)|Load(ingMXBean|er(Repository)?))?)|a(n(not(RedoExceptio
    n|UndoException|ProceedException)|cel(l(edKeyException|ationException)|ablePrint
    Job)|vas)|che(Re(sponse|quest)|dRowSet)|l(endar|l(able(Statement)?|back(Handler)
    ?))|r(dLayout|et(Event|Listener)?))|r(opImageFilter|edential(NotFoundException|E
    x(ception|piredException))))|T(hr(owable|ead(Group|MXBean|Info|Death|PoolExecuto
    r|Factory|Local)?)|ype(s|NotPresentException|InfoProvider|Variable)?|i(tledBorde
    r|e|leObserver|me(stamp|outException|Zone|Unit|r(MBean|Notification|Task|AlarmCl
    ockNotification)?|LimitExceededException)?)|oo(ManyListenersException|l(BarUI|Ti
    p(Manager|UI)|kit))|e(xt(Measurer|Syntax|HitInfo|Component|urePaint|InputCallbac
    k|OutputCallback|UI|Event|Field|L(istener|ayout)|A(ction|ttribute|rea))|mplates(
    Handler)?)|a(rget(edNotification|DataLine)?|gElement|b(S(top|et)|ular(Type|Data(
    Support)?)|Expander|le(Model(Event|Listener)?|HeaderUI|C(olumn(Model(Event|Liste
    ner)?)?|ell(Renderer|Editor))|UI|View)|ableView|bedPaneUI))|r(ust(Manager(Factor
    y(Spi)?)?|Anchor)|ee(M(odel(Event|Listener)?|ap)|Se(t|lection(Model|Event|Listen
    er))|Node|Cell(Renderer|Editor)|UI|Path|Expansion(Event|Listener)|WillExpandList
    ener)|a(ns(parency|f(orm(er(Handler|ConfigurationException|Exception|Factory(Con
    figurationError)?)?|Attribute)|er(Handler|able))|action(R(olledbackException|equ
    iredException)|alWriter)|mitter)|ck)))|I(n(s(t(an(ce(NotFoundException|AlreadyEx
    istsException)|tiationE(rror|xception))|rument(ation)?)|ufficientResourcesExcept
    ion|ets(UIResource)?)|herit(ed|ableThreadLocal)|comp(leteAnnotationException|ati
    bleClassChangeError)|t(Buffer|e(r(na(tionalFormatter|l(Error|Frame(UI|Event|Focu
    sTraversalPolicy|Listener|Adapter)))|rupt(ibleChannel|ed(NamingException|IOExcep
    tion|Exception)))|ger(Syntax)?)|rospect(ionException|or))|itial(Context(Factory(
    Builder)?)?|DirContext|LdapContext)|dex(ColorModel|edProperty(ChangeEvent|Descri
    ptor)|OutOfBoundsException)|put(M(ismatchException|ethod(Requests|Highlight|Cont
    ext|Descriptor|Event|Listener)?|ap(UIResource)?)|S(tream(Reader)?|ubset)|Context
    |Event|Verifier)|et(SocketAddress|4Address|Address|6Address)|v(ocation(Handler|T
    argetException|Event)|alid(R(ole(InfoException|ValueException)|elation(ServiceEx
    ception|TypeException|IdException))|M(idiDataException|arkException)|Search(Cont
    rolsException|FilterException)|NameException|ClassException|T(argetObjectTypeExc
    eption|ransactionException)|O(penTypeException|bjectException)|DnDOperationExcep
    tion|P(arameter(SpecException|Exception)|r(opertiesFormatException|eferencesForm
    atException))|Key(SpecException|Exception)|A(ctivityException|ttribute(sExceptio
    n|IdentifierException|ValueException)|pplicationException|lgorithmParameterExcep
    tion)))|flater(InputStream)?|lineView)|con(UIResource|View)?|te(ra(tor|ble)|m(Se
    lectable|Event|Listener))|dentity(Scope|HashMap)?|CC_(ColorSpace|Profile(RGB|Gra
    y)?)|IO(Re(ad(UpdateListener|ProgressListener|WarningListener)|gistry)|Metadata(
    Node|Controller|Format(Impl)?)?|ByteBuffer|ServiceProvider|I(nvalidTreeException
    |mage)|Param(Controller)?|Exception|Write(ProgressListener|WarningListener))|OEx
    ception|vParameterSpec|llegal(MonitorStateException|Block(ingModeException|SizeE
    xception)|S(tateException|electorException)|C(harsetNameException|omponentStateE
    xception|lassFormatException)|ThreadStateException|PathStateException|Format(Co(
    nversionException|dePointException)|PrecisionException|Exception|FlagsException|
    WidthException)|A(ccessE(rror|xception)|rgumentException))|mag(ingOpException|e(
    Read(er(Spi|WriterSpi)?|Param)|GraphicAttribute|C(onsumer|apabilities)|T(ypeSpec
    ifier|ranscoder(Spi)?)|I(nputStream(Spi|Impl)?|con|O)|O(utputStream(Spi|Impl)?|b
    server)|Producer|View|Filter|Write(Param|r(Spi)?))?))|Z(ip(InputStream|OutputStr
    eam|E(ntry|xception)|File)|oneView)|O(ceanTheme|ut(put(Stream(Writer)?|DeviceAss
    igned|Keys)|OfMemoryError)|p(tion(PaneUI|alDataException)?|e(n(MBean(Constructor
    Info(Support)?|Info(Support)?|OperationInfo(Support)?|ParameterInfo(Support)?|At
    tributeInfo(Support)?)|Type|DataException)|rati(ngSystemMXBean|on(sException|Not
    SupportedException)?)))|ver(la(yLayout|ppingFileLockException)|ride)|wner|rienta
    tionRequested|b(serv(er|able)|j(ID|ect(Stream(C(onstants|lass)|Exception|Field)|
    Name|ChangeListener|In(stance|put(Stream|Validation)?)|Output(Stream)?|View|Fact
    ory(Builder)?)?))|AEPParameterSpec)|D(GC|ynamicMBean|nDConstants|i(splayMode|cti
    onary|alog|r(StateFactory|Context|ect(oryManager|ColorModel)|ObjectFactory)|gest
    (InputStream|OutputStream|Exception)|mension(2D|UIResource)?)|SA(P(ublicKey(Spec
    )?|aram(s|eterSpec)|rivateKey(Spec)?)|Key(PairGenerator)?)|H(GenParameterSpec|P(
    ublicKey(Spec)?|arameterSpec|rivateKey(Spec)?)|Key)|o(c(ument(Builder(Factory)?|
    Name|ed|Parser|Event|Filter|Listener)?|PrintJob|Flavor|Attribute(Set)?)?|uble(Bu
    ffer)?|mainCombiner)|u(plicateFormatFlagsException|ration)|TD(Constants)?|e(s(cr
    iptor(Support|Access)?|t(ination|roy(able|FailedException))|ignMode|ktop(Manager
    |IconUI|PaneUI))|cimalFormat(Symbols)?|precated|f(later(OutputStream)?|ault(M(ut
    ableTreeNode|e(nuLayout|talTheme))|B(oundedRangeModel|uttonModel)|S(tyledDocumen
    t|ingleSelectionModel)|Highlighter|C(o(lorSelectionModel|mboBoxModel)|ellEditor|
    aret)|T(extUI|able(Model|C(olumnModel|ellRenderer))|ree(Model|SelectionModel|Cel
    l(Renderer|Editor)))|DesktopManager|PersistenceDelegate|EditorKit|KeyboardFocusM
    anager|Fo(cus(Manager|TraversalPolicy)|rmatter(Factory)?)|L(ist(Model|SelectionM
    odel|CellRenderer)|oaderRepository)))|l(egationPermission|ay(ed|Queue))|bugGraph
    ics)|OM(Result|Source|Locator)|ES(edeKeySpec|KeySpec)|at(e(Time(Syntax|At(C(ompl
    eted|reation)|Processing))|Format(ter|Symbols)?)?|a(Buffer(Byte|Short|Int|Double
    |UShort|Float)?|type(Con(stants|figurationException)|Factory)|Source|Truncation|
    Input(Stream)?|Output(Stream)?|gram(Socket(Impl(Factory)?)?|Channel|Packet)|F(or
    matException|lavor)|baseMetaData|Line))|r(iver(Manager|PropertyInfo)?|opTarget(C
    ontext|Dr(opEvent|agEvent)|Event|Listener|Adapter)?|ag(Gesture(Recognizer|Event|
    Listener)|Source(MotionListener|Context|Dr(opEvent|agEvent)|Event|Listener|Adapt
    er)?)))|U(R(I(Resolver|Syntax(Exception)?|Exception)?|L(StreamHandler(Factory)?|
    C(onnection|lassLoader)|Decoder|Encoder)?)|n(s(olicitedNotification(Event|Listen
    er)?|upported(C(harsetException|lassVersionError|allbackException)|OperationExce
    ption|EncodingException|FlavorException|LookAndFeelException|A(ddressTypeExcepti
    on|udioFileException))|atisfiedLinkError)|icastRemoteObject|d(o(Manager|ableEdit
    (Support|Event|Listener)?)|eclaredThrowableException)|expectedException|known(Gr
    oupException|ServiceException|HostException|ObjectException|Error|Format(Convers
    ionException|FlagsException))|re(solved(Permission|AddressException)|coverable(E
    ntryException|KeyException)|ferenced)|m(odifiable(SetException|ClassException)|a
    (ppableCharacterException|rshalException)))|til(ities|Delegate)?|TFDataFormatExc
    eption|I(Resource|Manager|D(efaults)?)|UID)|J(R(ootPane|adioButton(MenuItem)?)|M
    (RuntimeException|X(Serv(iceURL|erErrorException)|Connect(ionNotification|or(Ser
    ver(MBean|Provider|Factory)?|Provider|Factory)?)|Pr(incipal|oviderException)|Aut
    henticator)|enu(Bar|Item)?|Exception)|Button|S(croll(Bar|Pane)|p(inner|litPane)|
    eparator|lider)|o(in(RowSet|able)|b(Me(ssageFromOperator|diaSheets(Supported|Com
    pleted)?)|S(heets|tate(Reason(s)?)?)|HoldUntil|Name|Impressions(Supported|Comple
    ted)?|OriginatingUserName|Priority(Supported)?|KOctets(Supported|Processed)?|Att
    ributes))|dbcRowSet|C(heckBox(MenuItem)?|o(lorChooser|m(ponent|boBox)))|T(o(ol(B
    ar|Tip)|ggleButton)|ext(Component|Pane|Field|Area)|ab(le(Header)?|bedPane)|ree)|
    InternalFrame|OptionPane|D(ialog|esktopPane)|P(opupMenu|EG(HuffmanTable|Image(Re
    adParam|WriteParam)|QTable)|a(sswordField|nel)|rogressBar)|EditorPane|ar(InputSt
    ream|OutputStream|URLConnection|E(ntry|xception)|File)|Viewport|F(ileChooser|orm
    attedTextField|rame)|Window|L(ist|a(yeredPane|bel))|Applet)|P(hantomReference|BE
    (ParameterSpec|Key(Spec)?)|i(pe(d(Reader|InputStream|OutputStream|Writer))?|xel(
    Grabber|InterleavedSampleModel))|S(SParameterSpec|ource)|o(sition|int(2D|erInfo)
    ?|oledConnection|pup(Menu(UI|Event|Listener)?|Factory)?|l(ygon|icy(Node|Qualifie
    rInfo)?)|rt(UnreachableException|ableRemoteObject(Delegate)?)?)|u(shback(Reader|
    InputStream)|blicKey)|er(sisten(ceDelegate|tMBean)|mission(s|Collection)?)|DLOve
    rrideSupported|lain(Document|View)|a(ssword(Callback|View|Authentication)|nel(UI
    )?|ck(200|edColorModel|age)|t(hIterator|ch|tern(SyntaxException)?)|int(Context|E
    vent)?|per|r(se(Position|Exception|r(ConfigurationException|Delegator)?)|tialRes
    ultException|a(graphView|meter(MetaData|Block|izedType|Descriptor)))|ge(sPerMinu
    te(Color)?|Ranges|dResults(ResponseControl|Control)|able|Format|Attributes))|K(C
    S8EncodedKeySpec|IX(BuilderParameters|CertPath(BuilderResult|Checker|ValidatorRe
    sult)|Parameters))|r(i(n(cipal|t(RequestAttribute(Set)?|Graphics|S(tream|ervice(
    Lookup|Attribute(Set|Event|Listener)?)?)|er(Resolution|Graphics|M(oreInfo(Manufa
    cturer)?|essageFromOperator|akeAndModel)|State(Reason(s)?)?|Name|I(sAcceptingJob
    s|nfo|OException)|URI|Job|Exception|Location|AbortException)|Job(Event|Listener|
    A(ttribute(Set|Event|Listener)?|dapter))?|E(vent|xception)|able|Quality|Writer))
    |ority(BlockingQueue|Queue)|v(ileged(ExceptionAction|Action(Exception)?)|ate(MLe
    t|C(lassLoader|redentialPermission)|Key)))|o(cess(Builder)?|t(ocolException|ecti
    onDomain)|pert(y(ResourceBundle|Change(Support|Event|Listener(Proxy)?)|Descripto
    r|Permission|Editor(Manager|Support)?|VetoException)|ies)|vider(Exception)?|file
    DataException|gress(Monitor(InputStream)?|BarUI)|xy(Selector)?)|e(sentationDirec
    tion|dicate|paredStatement|ference(s(Factory)?|Change(Event|Listener)))))|E(n(c(
    ode(dKeySpec|r)|ryptedPrivateKeyInfo)|tity|um(Map|S(yntax|et)|Con(stantNotPresen
    tException|trol)|eration)?)|tchedBorder|ditorKit|C(GenParameterSpec|P(oint|ublic
    Key(Spec)?|arameterSpec|rivateKey(Spec)?)|Key|Field(F(2m|p))?)|OFException|vent(
    SetDescriptor|Handler|Context|Object|DirContext|Queue|Listener(Proxy|List)?)?|l(
    ement(Type|Iterator)?|lip(se2D|ticCurve))|rror(Manager|Listener)?|x(c(hanger|ept
    ion(InInitializerError|Listener)?)|te(ndedRe(sponse|quest)|rnalizable)|p(ortExce
    ption|andVetoException|ression)|e(cut(ionException|or(s|Service|CompletionServic
    e)?)|mptionMechanism(Spi|Exception)?))|mpty(Border|StackException))|V(MID|i(sibi
    lity|ew(port(UI|Layout)|Factory)?|rtualMachineError)|o(i(ceStatus|d)|latileImage
    )|e(ctor|toableChange(Support|Listener(Proxy)?)|rifyError)|a(l(idator(Handler)?|
    ue(Handler(MultiFormat)?|Exp))|riableHeightLayoutCache))|Ke(y(Rep|Generator(Spi)
    ?|Manage(r(Factory(Spi)?)?|mentException)|S(t(ore(BuilderParameters|Spi|Exceptio
    n)?|roke)|pec)|Pair(Generator(Spi)?)?|E(vent(Dispatcher|PostProcessor)?|xception
    )|Factory(Spi)?|map|boardFocusManager|Listener|A(dapter|lreadyExistsException|gr
    eement(Spi)?))?|r(nel|beros(Ticket|Principal|Key)))|Q(Name|u(e(ue(dJobCount)?|ry
    (E(val|xp))?)|adCurve2D))|F(i(nishings|delity|eld(Position|View)?|l(ter(Reader|I
    nputStream|ed(RowSet|ImageSource)|OutputStream|Writer)?|e(Reader|nameFilter|Syst
    emView|Handler|N(otFoundException|ameMap)|C(h(ooserUI|annel)|acheImage(InputStre
    am|OutputStream))|I(nputStream|mage(InputStream|OutputStream))|OutputStream|D(ia
    log|escriptor)|Permission|View|Filter|Writer|Lock(InterruptionException)?)?)|xed
    HeightLayoutCache)|o(nt(RenderContext|Metrics|UIResource|FormatException)?|cus(M
    anager|TraversalPolicy|Event|Listener|Adapter)|rm(SubmitEvent|at(t(er(ClosedExce
    ption)?|able(Flags)?)|ConversionProvider|FlagsConversionMismatchException)?|View
    ))|uture(Task)?|eatureDescriptor|l(o(w(View|Layout)|at(Buffer|Control)?)|ushable
    |a(tteningPathIterator|vor(Map|Table|E(vent|xception)|Listener)))|a(ctoryConfigu
    rationError|iledLoginException)|rame)|W(i(ndow(StateListener|Constants|Event|Foc
    usListener|Listener|Adapter)?|ldcardType)|e(ak(Reference|HashMap)|bRowSet)|r(it(
    e(r|AbortedException)|able(R(enderedImage|aster)|ByteChannel))|appedPlainView))|
    L(i(st(ResourceBundle|Model|Selection(Model|Event|Listener)|CellRenderer|Iterato
    r|enerNotFoundException|Data(Event|Listener)|UI|View)?|n(e(Metrics|B(order|reakM
    easurer)|2D|Number(Reader|InputStream)|UnavailableException|Event|Listener)?|k(R
    ef|ed(BlockingQueue|Hash(Map|Set)|List)|Exception|ageError|LoopException))|mitEx
    ceededException)|o(ng(Buffer)?|c(k(Support)?|a(teRegistry|le))|ok(up(Table|Op)|A
    ndFeel)|aderHandler|g(Record|Manager|in(Module|Context|Exception)|Stream|g(ing(M
    XBean|Permission)|er)))|dap(ReferralException|Name|Context)|e(vel|ase)|DAPCertSt
    oreParameters|a(stOwnerException|y(out(Manager(2)?|Queue|FocusTraversalPolicy)|e
    redHighlighter)|nguageCallback|bel(UI|View)?))|A(s(sertionError|ync(hronousClose
    Exception|BoxView))|n(notat(ion(TypeMismatchException|FormatError)?|edElement)|c
    estor(Event|Listener))|c(c(ount(NotFoundException|Ex(ception|piredException)|Loc
    kedException)|ess(ible(R(ole|e(sourceBundle|lation(Set)?))|Bundle|S(t(ate(Set)?|
    reamable)|election)|Hyper(text|link)|Co(ntext|mponent)|T(ext(Sequence)?|able(Mod
    elChange)?)|Icon|Object|E(ditableText|xtended(Component|T(ext|able)))|Value|KeyB
    inding|A(ction|ttributeSequence))?|Control(Context|Exception|ler)|Exception))|ti
    (on(Map(UIResource)?|Event|Listener)?|v(ity(RequiredException|CompletedException
    )|eEvent|at(ion(Group(_Stub|ID|Desc)?|Monitor|System|I(nstantiator|D)|Desc|Excep
    tion)|or|eFailedException|able)))|l(NotFoundException|Entry)?)|t(tribute(s|Modif
    icationException|Set(Utilities)?|d(String|CharacterIterator)|NotFoundException|C
    hangeNotification(Filter)?|InUseException|Exception|ValueExp|List)?|omic(Referen
    ce(FieldUpdater|Array)?|MarkableReference|Boolean|StampedReference|Integer(Field
    Updater|Array)?|Long(FieldUpdater|Array)?))|d(just(able|ment(Event|Listener))|le
    r32)|u(t(h(orizeCallback|enticat(ion(NotSupportedException|Exception)|or)|P(ermi
    ssion|rovider))|oscroll)|dio(System|Clip|InputStream|Permission|F(ile(Reader|For
    mat|Writer)|ormat)))|pp(ConfigurationEntry|endable|let(Stub|Context|Initializer)
    ?)|ffineTransform(Op)?|l(phaComposite|lPermission|ready(BoundException|Connected
    Exception)|gorithmParameter(s(Spi)?|Generator(Spi)?|Spec))|r(c2D|ithmeticExcepti
    on|ea(AveragingScaleFilter)?|ray(s|BlockingQueue|StoreException|Type|IndexOutOfB
    oundsException|List)?)|bstract(M(ethodError|ap)|B(order|utton)|S(pinnerModel|e(t
    |quentialList|lect(ionKey|or|ableChannel)))|C(ol(orChooserPanel|lection)|ellEdit
    or)|TableModel|InterruptibleChannel|Document|UndoableEdit|Preferences|ExecutorSe
    rvice|Queue(dSynchronizer)?|Writer|L(ist(Model)?|ayoutCache)|Action)|WT(Permissi
    on|E(vent(Multicaster|Listener(Proxy)?)?|rror|xception)|KeyStroke)))
  TYPES
  
  def test_very_long
    assert_scans_list_size JAVA_BUILTIN_TYPES,             2389
    assert_scans_list_size JAVA_BUILTIN_TYPES + '?',       2389 + 1
    assert_scans_list_size JAVA_BUILTIN_TYPES + '(A|B)',   2389      * 2
    assert_scans_list_size JAVA_BUILTIN_TYPES + '?(A|B)', (2389 + 1) * 2
  end
  
end

puts SimpleRegexpScanner.new(SimpleRegexpScannerTest::JAVA_BUILTIN_TYPES).list