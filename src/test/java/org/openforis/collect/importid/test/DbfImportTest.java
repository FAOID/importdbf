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
		/*
		 * KEY is 4717003009302060
		 * 47 = zone 
		 * 170 = easting
		 * 0300 = northing
		 * 93 = inventory year
		 * 0 = control number
		 * 2 = track number
		 * 06 = sub plot number
		 * 0 = small or big part
		 * 
		 */
		CharField key = (CharField) dbfFile.getField("KEY");
		for (int i = 1; i <= dbfFile.getRecordCount(); i++)
		{
			dbfFile.read();
			System.out.println(i + ":" + key.get());
		}
	}
}
