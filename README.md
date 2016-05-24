# Escuela Politécnica Nacional
# Lenguajes y Compiladores

# José Limaico, Andrés Salazar

# Clase AnalizadorSB
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import javax.swing.JFileChooser;

public class AnalizadorSB {
    
    public String llenarFichero() throws FileNotFoundException, IOException{
        String cadena;
        File a;
        JFileChooser ch = new JFileChooser();
        ch.showOpenDialog(ch);
        String path=ch.getSelectedFile().getAbsolutePath();
        String leer="";
        a=new File(path);
            FileReader fr= new FileReader(a);
            BufferedReader br= new BufferedReader(fr);
            while((cadena=br.readLine())!=null){
                leer=leer+cadena+"\n";
                //System.out.println(cadena);
            }
            br.close();
            return leer;
        
    }
    
}



import java.io.IOException;
import java.util.StringTokenizer;




public class AnalizadorSintacticoBasico {

    /**
     * @param args the command line arguments
     */
    
    
    public static void main(String[] args) throws IOException {
        // TODO code application logic here
        String [] cad={"tipo_de_dato variable;","variable = expresion ;","vector [ expresion ] = expresion ;","if ( expresion ) then comando ;"}; 
        
        int n=0;
        AnalizadorSB al =new AnalizadorSB();
        
        StringTokenizer tokens = new StringTokenizer(al.llenarFichero(), "\n");
    String[] exp = new String[tokens.countTokens()] ;
        
    
    for(int i=0;i<exp.length;i++){
           exp[i]=tokens.nextToken();
          
    }
    
    for(int i=0;i<exp.length;i++)
      n=cad[i].compareTo(exp[i]);
     
    if(n==0){
        System.out.println("error sintactico");   
     }
    else{
        System.out.println("su sintaxis esta correcta");
    }
        
    }
}

#Documento con las tokens classes evaluadas en el ejercicio

tipo_de_dato variable;
variable = expresion ;
vector [ expresion ] = expresion ;
if ( expresion ) then comando ;

