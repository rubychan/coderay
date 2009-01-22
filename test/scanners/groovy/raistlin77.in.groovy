package de.intex.xml;

import groovy.xml.MarkupBuilder;
import it.sauronsoftware.base64.Base64;

/**
 * XML-Builder Class für den XML-Server der EEi.
 *
 * <li>TODO: getBLOB/putBLOB bei Massenim/-exports (Protokollbelastung)
 *
 */

public class RequestBuilder {

  private String user
  private String password
  private String head = '<?xml version="1.0" encoding="UTF-8" ?>'
  private String lastRequest = "";
  private Integer reqID = 1;

  /**
   * Konstruktur für das XMLRequestBuild-Object mit User und Passwort.
   */
  RequestBuilder(String user, String password){
    this.user = user;
    this.password = Base64.encode(password);
  }

  /**
   * Eine eintrag im Easy Logbuch. XML-Build muß übergeben werden.
   * Ist für interes logging des Builders gedacht
   * type: INFO || ERROR
   * logclass: EASY || SYSTEM || DEBUG
   */
  private getLogEntry(xml, type, logclass, message){
    xml.LOG( message, REQUESTID:newReqID(), TYPE:type, CLASS:logclass )
  }

  /**
   * Helper Funktion für das Bilden eines Requestes.
   * Wird von der Request Funktion aufgerufen und bildet den kompletten Request.
   * Ruft den übergeben Closure auf und den Request spezifischen Code in das XML
   * ein zubinden.
   */
  private String buildRequest(closure){
    def writer = new StringWriter()
    def xml = new MarkupBuilder(writer)
    xml.REQUEST( XMLID:"SYSTEM_"+newReqID() ){
      loginRequest( xml )
      closure( xml )
      logutRequest( xml )
    }
    lastRequest = head + "\n" + writer.toString()
    return lastRequest;
  }

  /**
   * XML-Teilrequest für das einloggen
   */
  private void logutRequest(xml){
    //xml.LOGOUT( REQUESTID:newReqID() )
  }

  /**
   * XML-Teilrequest für das ausloggen
   */
  private void loginRequest(xml){
    xml.LOGIN( REQUESTID:newReqID() ){
      USERNAME( user )
      PASSWORD( password )
    }
  }

  /**
   * build note method called from varius methods
   */
  private String buildNote( argprops ){
    def props = [ REQUESTID:newReqID() ]
    props.putAll( argprops )
    return buildRequest( ){
      it.NOTE( props )
    }
  }

  /**
   * Fortlaufende RequestID innerhalb einer Instance
   */
  private newReqID(){
    try{
      reqID += 1;
    } catch( ArithmeticException e){
      reqID = 1;
    }
    return reqID;
  }

  /**
   * bilde Easy-Documentenschreibweise aus Lagerort und Archiv oder EasyArchivReferenz und Mappe+Version
   */
  public String buildEasyDocRef(location, archiv=null, mappe=null, version=null){
    if(!mappe || !version){
       throw new RuntimeException("Keine Mappe oder Version angegeben ${mappe},${version}")
    } else {
       return buildEasyArchivRef(location, archiv) + ',' + mappe + ',' + version;
     }
  }

  /**
   * bilde Easy-Archivschreibweise aus Lagerort und Archiv
   */
  public String buildEasyArchivRef(location, archive=null){
    def locarc
    if( archive ){
       locarc = "\$(#${location})\\${archive}"
    } else {
       locarc = location;
     }
    return locarc
  }

  /**
   * Request für die Liste aller Lagerorte
   */
  public String getLocations(category="ALL"){
    return buildRequest(){
      it.LOCATIONS(REQUESTID:newReqID()){
        CATEGORY(category)
      }
    }
  }

  /**
   * Request für die Archive eines Lagerortes
   */
  public String getArchives(location){
    return buildRequest(){
      it.ARCHIVES(REQUESTID:newReqID(), LOCATION:location)
    }
  }

  /**
   * Eine eintrag im Easy Logbuch. XML-Build muß übergeben werden.
   * type: INFO || ERROR
   * logclass: EASY || SYSTEM || DEBUG
   */
  public String getLog( type, logclass, message ){
    return buildRequest(){ xml ->
       getLogEntry(xml, type, logclass, message)
     }
  }

  /**
   * Request für die Beschreibung eines Archives
   * section kann folgende (auch mehrere) Wert enthalten:
   * FIELDLIST, HITLISTS, SEARCHMASKS, STATISTICS, RIGHTS, BITMAPS, SELLISTS
   */
  public String getArchiveDescription(section, location, archive=null){
    def locarc = buildEasyArchivRef( location, archive )
    return buildRequest(){
      it.ARCDESCRIPTION( REQUESTID:newReqID(), ARCHIVE:locarc, SECTION:section )
    }
  }

  /**
   * Liste die Notizen eine Mappe auf
   */
  public String getNoteList( easydocref ){
    return buildNote( MODE:'LIST', EASYDOCREF:easydocref )
  }

  /**
   * Liest eine Notiz einer Mappe
   */
  public String getNoteRead( easydocref, noteid ){
    return buildNote( MODE:'READ', EASYDOCREF:easydocref, NOTEID:noteid )
  }

  /**
   * Abfrage des Gossars eines Archives
   */
  public String getGlossary(locarc, query, cnt){
    return buildRequest(){
      it.GLOSSARY( REQUESTID:newReqID(), ARCHIVE:locarc, QUERY:query, COUNT:cnt )
    }
  }

  /**
   * Importtiert eine Mappe inklusive BLOBs in das Archiv
   */
  public String getUpdate(archivref, mappe, version, fields, blobs){
    int cnt = fields.size() + blobs.size()
    int id = -1;
    int blobid=2000;
    return buildRequest(){ xml->
      xml.IMPORT( REQUESTID:newReqID(), ARCHIVE:archivref, MODE:'SYNC', FOLDER:''){
        DOCUMENT( ID:'DOCID_1', FIELDCOUNT:cnt, EASYDOCREF:buildEasyDocRef(archivref, null, mappe, version ) ){
          fields.each(){ field ->
            FIELD( CODE:'ANSI', TYPE:'STRING', NAME:field.key, ID:(id+=1), USE:'USER' ){
              DATA(){
                xml.yieldUnescaped( '<![CDATA[' + field.value + ']]>' )
              }
            }
          }
          blobs.each(){ blob ->
            FIELD( TYPE:'BLOB', NAME:(blobid+=1), ID:(id+=1), USE:'USER'){
              blob.each(){ fl ->
                "${fl.key}"(fl.value)
              }
              DATA('no data requested.')
            }
          }
        }
      }
    }
  }

  /**
   * Importtiert eine Mappe inklusive BLOBs in das Archiv
   */
  public String getImport(archivref, fields, blobs){
    int cnt = fields.size() + blobs.size()
    int id = -1;
    return buildRequest(){ xml->
      xml.IMPORT( REQUESTID:newReqID(), ARCHIVE:archivref, MODE:'SYNC', FOLDER:''){
        DOCUMENT( ID:'DOCID_1', FIELDCOUNT:cnt ){
          fields.each(){ field ->
            FIELD( CODE:'ANSI', TYPE:'STRING', NAME:field.key, ID:(id+=1), USE:'USER' ){
              DATA(){
                xml.yieldUnescaped( '<![CDATA[' + field.value + ']]>' )
              }
            }
          }
        }
      }
    }
  }

  /**
   * Holt ganzes Dokument aus dem Archiv mit/ohne BLOBs oder einzelne Felder/BLOBs
   */
  public String getDocument(docref, blobdata, blobid, fieldid, intfields ){
    return buildRequest(){
      it.DOCUMENT( REQUESTID:newReqID(), EASYDOCREF:docref, BLOBID:blobid, BLOBDATA:blobdata, FIELDID:fieldid, INTFIELDS:intfields, RENDERER:'0', IFRCCODEB64:'1' )
    }
  }

  /**
   * Löscht eine mappe anhand Ihrer Easy Referenz
   */
  public String getDelete(easyref){
    return buildRequest(){
       it.DELETE( REQUESTID:newReqID(), EASYDOCREF:easyref )
     }
  }

  /**
   * gibt den letzen Request zurück. Nützlich für die Fehler analyse.
   * Da so der Fehlerhafte Request genauer betrachtet werden kann.
   */
  public String getLastRequest(){
    return lastRequest;
  }

  /**
   * Request für einen oder mehreren Suchbegriffen aus einem oder mehreren Archiven.
   *
   * <li>Suche in meheren archiven mit mehereren Feldern
   * getQueryArchives(["arch1", "arch2"], ['.Mappe'="00001083", '.Version'="001"], "SYSTEM", 20, 0)
   *
   * <li>Volltextsuche in einem Archiv
   * getQueryArchives("arch1", "00001083", "SYSTEM", 20, 0)
   *
   */
  public String getQuery(archives, queries, hitlist="SYSTEM", maxcount="20", hitpos="0"){
    def querystring
    if( archives.getClass() == String ){
      archives = [ archives ];
    }
    switch( queries.getClass() ){
      case LinkedHashMap:
        querystring = queries.collect(){ "(.${it.key}=${it.value})" }.join('&')
      break
      default:
        querystring = queries
      break
    }
    def ret = buildRequest(){
      it.QUERY(REQUESTID:newReqID(), HITLIST:hitlist, MAXHITCOUNT:maxcount, HITPOSITION:hitpos, ARCHIVE:archives.pop()){
        archives.each(){ arc ->
          ARCHIVE(arc)
        }
        QUERYSTRING(querystring)
      }
    }
  }

}

package de.intex.xml;

import it.sauronsoftware.base64.Base64

public class ResponseParser {

  private String lastResponse = "";
  private String lastError = null;
  static private PROPERTIES = [:]

  static {
    PROPERTIES['LOCATION']        = [ 'CATEGORY', 'NAME' ]
    PROPERTIES['ARCHIVE']         = [ 'NAME' ]
    PROPERTIES['FIELD']           = [ 'NAME', 'TYPE', 'EASYID' ]
    PROPERTIES['TABFIELD']        = [ 'NAME', 'FORMAT', 'VISIBLELENGTH', 'ORDER', 'EASYID', 'SORTINDEX', 'NUMBER' ]
    PROPERTIES['SEARCHFIELD']     = [ 'NAME', 'NUMBER', 'EASYID', 'YPOS', 'XPOS', 'LENGTH', 'LABELPOS' ]
    PROPERTIES['HITLINE']         = [ 'NUMBER', 'EASYDOCREF' ]
    PROPERTIES['HITLIST']         = [ 'NAME', 'HITCOUNT' ]
    PROPERTIES['HITLINETABFIELD'] = [ 'NUMBER' ]
    PROPERTIES['DOCUMENT']        = [ 'FIELDCOUNT', 'ID', 'EDITED', 'CREATION', 'ARCHIVED' ]
    PROPERTIES['DOCUMENTFIELD']   = [ 'NAME', 'ATTRIB', 'SEGMID', 'USE=USER', 'ID', 'TYPE', 'CODE' ]
    PROPERTIES['GLOSSARYWORD']    = [ 'NAME' ]
    PROPERTIES['IMPORT']          = [ 'ARCHIVE' ]
    PROPERTIES['IMPORTDOCUMENT']  = [ 'EASYDOCREF' ]
  }

  /**
   * Konstruktur für das XMLResponseParser-Objekt.
   */
  ResponseParser(){
    ///
  }

  /**
   * gibt den letzen Request zurück. Nützlich für die Fehler analyse.
   * Da so der Fehlerhafte Request genauer betrachtet werden kann.
   */
  public String getLastResponse(){
    return lastResponse;
  }

  /*
   *
   *
   */
  private getProperties(ln, prop, desc=false){
    def ret = [:]
    if(desc) ret['TEXT'] = ln.text()
    prop.each(){ it ->
      ret[it] = ln.attribute( it )
    }
    return ret;
  }

  /**
   * parsed den übergeben Response String.
   * Ist einer oder mehrere Fehler/Error vorhanden
   * wird lastError mit einer Fehlermeldung gesetzt.
   */
  def parse(String response) throws ParserException {
    lastResponse = response;
    lastError = null;
    def tmpError = [];

    def xml = new XmlParser().parseText( response )

    if( xml.ERROR.size() > 0 ){
      xml.ERROR.each(){
        tmpError << "Kommando:'${it.@COMMAND}' Fehler: '${it.@ERRORNUMBER}' '${it.text()}'"
      }
      lastError = tmpError.join("\n");
      throw( new ParserException( lastError ) )
      return null;
    }

    def suc = xml.SUCCESS

    if( suc.size() <= 0  ){
      lastError = "Keine Request Informationen zur Verabeitung vorhanden"
      throw( new ParserException( lastError ) )
      return null;
    }

    def ret = [:]

    suc.each(){ sucNode ->
      println sucNode.@COMMAND
      switch( sucNode.@COMMAND ){
        case 'LOG':
        case 'LOGIN':
        case 'LOGOUT':
        case 'DELETE':
          ret[ sucNode.@COMMAND ] = 'OK'
        break;
        case 'GLOSSARY':
        case 'ARCHIVES':
        case 'LOCATIONS':
          ret[ sucNode.@COMMAND ] = []
          sucNode.each(){ ln -> ret[ sucNode.@COMMAND ] << getProperties( ln, PROPERTIES[ ln.name() ], true ) }
        break;
        case 'ARCDESCRIPTION':
          ret[ sucNode.@COMMAND ] = [:]
          sucNode.ARCDESCRIPTION[0].each(){ arcDesc ->
            switch(arcDesc.name()){
              case 'FIELDLIST':
                ret[ sucNode.@COMMAND ][ arcDesc.name() ] = []
                arcDesc.each(){ ln ->
                  ret[ sucNode.@COMMAND ][ arcDesc.name() ] << getProperties( ln, PROPERTIES[ ln.name() ] )
                }
              break;
              case 'SEARCHMASKS':
              case 'HITLISTS':
                ret[ sucNode.@COMMAND ][ arcDesc.name() ] = [:]
                arcDesc.each(){ lists ->
                  ret[ sucNode.@COMMAND ][ arcDesc.name() ][ lists.@NAME ] = []
                  lists.each(){ ln ->
                    ret[ sucNode.@COMMAND ][ arcDesc.name() ][ lists.@NAME ] << getProperties(ln, PROPERTIES[ ln.name()] )
                  }
                }
              break;
              case 'STATISTICS':
                ret[ sucNode.@COMMAND ][ arcDesc.name() ] = [:]
                ['DOCCOUNT', 'INDEXCOUNT', 'ARCSIZE', 'ARCSIZETRANSFERRED', 'ARCSIZEDOCUMENTS', 'ARCSIZEQUERY', 'ARCSIZENOTICE'].each(){
                  ret[ sucNode.@COMMAND ][ arcDesc.name() ][ it ] = arcDesc."$it".text()
                }
              break;
              default:
                lastError = "Unbekannter Request-Typ: '${sucNode.@COMMAND}' '${arcDesc.name()}'"
                throw( new ParserException(lastError) )
              break;
            }
          }
        break;
        case 'QUERY':
          ret[ sucNode.@COMMAND ] = [:]
          ret[ sucNode.@COMMAND ]['HITLIST'] = getProperties( sucNode.HITLIST[0], PROPERTIES['HITLIST'] )
          ret[ sucNode.@COMMAND ]['HITLINE'] = []
          sucNode.HITLIST[0].each(){ ln ->
            def tmp = getProperties(ln, PROPERTIES[  ln.name() ])
            tmp['TABFIELD'] = []
            ln.each(){ tab ->
              tmp['TABFIELD'] << getProperties(tab, PROPERTIES[  ln.name()+tab.name() ], true)
            }
            ret[ sucNode.@COMMAND ]['HITLINE'] << tmp
          }
        break;
        case 'IMPORT':
          println("-------------")
          println sucNode[ sucNode.@COMMAND ][0]
          println sucNode[ sucNode.@COMMAND ].DOCUMENT[0]
          println("-------------")
          ret[ sucNode.@COMMAND ] = getProperties( sucNode[ sucNode.@COMMAND ][0], PROPERTIES['IMPORT'] )
          ret[ sucNode.@COMMAND ]['DOCUMENT'] = getProperties( sucNode[ sucNode.@COMMAND ].DOCUMENT[0], PROPERTIES['IMPORTDOCUMENT'] )
        break;
        case 'DOCUMENT':
          ret[ sucNode.@COMMAND ] = getProperties( sucNode.DOCUMENT[0], PROPERTIES['DOCUMENT'] )
          ret[ sucNode.@COMMAND ]['FIELD'] = []
          sucNode.DOCUMENT[0].each(){ ln ->
            def tmp = getProperties( ln, PROPERTIES['DOCUMENTFIELD'], true )
            tmp['DATA'] = [:]
            ln.each(){ dta ->
              //println tmp['TYPE']
              //println tmp['CODE']
              if( tmp['CODE']=='BASE64' && dta.name()=='DATA' && dta.text()!='no data requested'){
                tmp['DATA'][ dta.name() ] = Base64.decode( dta.text() )
                //tmp['DATA'][ dta.name() ] = 'base64'
              } else {
                tmp['DATA'][ dta.name() ] = dta.text()
              }
            }
            ret[ sucNode.@COMMAND ]['FIELD'] << tmp
          }
          //println sucNode
        break;
        default:
          lastError = "Unbekannter Request-Typ: '${sucNode.@COMMAND}'"
          throw( new ParserException(lastError) )
        break;
      }
    }

    return ret;
  }

}
