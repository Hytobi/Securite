import javax.net.ssl.*;
import java.security.KeyStore;

public class SSLUtils {
    public static SSLServerSocketFactory createSSLServerSocketFactory(String keystoreFile, String password) throws Exception {
        KeyStore ks = KeyStore.getInstance("JKS");
        ks.load(new java.io.FileInputStream("keystore/" + keystoreFile), password.toCharArray());

        KeyManagerFactory kmf = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        kmf.init(ks, password.toCharArray());

        SSLContext sc = SSLContext.getInstance("TLS");
        sc.init(kmf.getKeyManagers(), null, null);

        return sc.getServerSocketFactory();
    }

    public static SSLSocketFactory createSSLSocketFactory(String truststoreFile, String password) throws Exception {
        KeyStore ts = KeyStore.getInstance("JKS");
        ts.load(new java.io.FileInputStream("truststore/" + truststoreFile), password.toCharArray());

        TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        tmf.init(ts);

        SSLContext sc = SSLContext.getInstance("TLS");
        sc.init(null, tmf.getTrustManagers(), null);

        return sc.getSocketFactory();
    }
}
