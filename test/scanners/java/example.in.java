package pl.silvermedia.ws;
import java.util.List;

import javax.jws.WebParam;
import javax.jws.WebService;

@WebService
public interface ContactUsService {
  List<Message> getMessages();
  Message getFirstMessage();
    void postMessage(@WebParam(name = "message") Message message);
}
