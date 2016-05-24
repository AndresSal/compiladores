# compiladores
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

