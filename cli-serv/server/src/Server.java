import javax.net.ssl.*;
import java.io.*;

public class Server {
    public static void main(String[] args) {
        int port = 8443;
        try {
            SSLServerSocketFactory ssf = SSLUtils.createSSLServerSocketFactory("server-keystore.jks", "password");
            SSLServerSocket serverSocket = (SSLServerSocket) ssf.createServerSocket(port);

            System.out.println("Serveur SSL démarré sur le port " + port);
            while (true) {
                SSLSocket socket = (SSLSocket) serverSocket.accept();
                new Thread(() -> handleClient(socket)).start();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void handleClient(SSLSocket socket) {
        try (BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
             BufferedWriter out = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream()))) {

            String message = in.readLine();
            System.out.println("Reçu du client : " + message);

            out.write("Message reçu : " + message + "\n");
            out.flush();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
