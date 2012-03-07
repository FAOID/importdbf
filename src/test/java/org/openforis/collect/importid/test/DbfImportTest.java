package org.openforis.collect.importid.test;
import java.io.IOException;
import java.net.URL;

import junit.framework.Assert;
import org.junit.Test;
import org.xBaseJ.DBF;
import org.xBaseJ.xBaseJException;
import org.xBaseJ.fields.CharField;


public class DbfImportTest {
	@Test
	public void testImport() throws xBaseJException, IOException  {
		URL dbf = ClassLoader.getSystemResource("cluster/sample/RT1.DBF");
		DBF dbfFile=new DBF(dbf.getPath());
		Assert.assertNotNull(dbfFile.getName());
		
		CharField key = (CharField) dbfFile.getField("KEY");
		for (int i = 1; i <= dbfFile.getRecordCount(); i++)
		{
			dbfFile.read();
			System.out.println(i + ":" + key.get());
			
		}
	}
}
