if(!([System.Net.ServicePointManager]::CertificatePolicy.ToString() -eq 'TrustAllCertsPolicy')){
  
  add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
  [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}
            
$w = Invoke-WebRequest -Uri "https://$ip" -UseBasicParsing -ErrorAction SilentlyContinue
