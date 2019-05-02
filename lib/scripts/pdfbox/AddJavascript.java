package pdfbox;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.interactive.action.PDActionJavaScript;

import java.io.File;
import java.io.IOException;


public class AddJavascript
{

	public static void main(String args[]) throws Exception {

	      //Loading an existing file
	      String inputFileName = args[0];
	      String hashId = args[1];
	      String baseUrl = args[2];

	      File inputFile = new File(inputFileName);
	      PDDocument inputDocument = PDDocument.load(inputFile);
	      String url = baseUrl+"/v0/thank_you?id="+hashId;

              String javaScript = "this.getURL(\""+url+"\", false)";

	      PDActionJavaScript PDAjavascript = new PDActionJavaScript(javaScript);

	      //Embedding java script
	      inputDocument.getDocumentCatalog().setOpenAction(PDAjavascript);

	      inputFile.delete();

	      //Saving the document
	      inputDocument.save( new File(inputFileName) );
	      System.out.println("Data added to the given PDF");

	      //Closing the document
	      inputDocument.close();

	   }

}

