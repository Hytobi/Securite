import javax.net.ssl.*;
import java.io.*;

public class Client {
    public static void main(String[] args) {
        String host = "server";
        int port = 8443;
        try {
            SSLSocketFactory ssf = SSLUtils.createSSLSocketFactory("client-truststore.jks", "password");
            SSLSocket socket = (SSLSocket) ssf.createSocket(host, port);

            try (BufferedWriter out = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream()));
                 BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()))) {

                out.write("Bonjour depuis le client !\n");
                out.flush();

                String response = in.readLine();
                System.out.println("Réponse du serveur : " + response);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
