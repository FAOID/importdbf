package org.openforis.collect.importid.test;

import java.io.File;
import java.io.FileFilter;
import java.io.FilenameFilter;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;

import junit.framework.Assert;

import org.apache.commons.lang3.text.WordUtils;
import org.jooq.Field;
import org.jooq.Record;
import org.jooq.SelectConditionStep;
import org.jooq.impl.Factory;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.openforis.collect.manager.SurveyManager;
import org.openforis.collect.manager.UserManager;
import org.openforis.collect.model.CollectRecord;
import org.openforis.collect.model.User;
import org.openforis.collect.model.CollectRecord.Step;
import org.openforis.collect.model.CollectSurvey;
import org.openforis.collect.persistence.RecordDao;
import org.openforis.collect.persistence.TaxonDao;
import org.openforis.collect.persistence.TaxonVernacularNameDao;
import org.openforis.collect.persistence.TaxonomyDao;
import org.openforis.collect.persistence.jooq.DialectAwareJooqFactory;
import org.openforis.idm.model.Code;
import org.openforis.idm.model.Entity;
import org.openforis.idm.model.IntegerAttribute;
import org.openforis.idm.model.IntegerValue;
import org.openforis.idm.model.RealAttribute;
import org.openforis.idm.model.species.Taxon;
import org.openforis.idm.model.species.TaxonVernacularName;
import org.openforis.idm.model.species.Taxonomy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.xBaseJ.DBF;
import org.xBaseJ.xBaseJException;
import org.xBaseJ.fields.CharField;
import org.xBaseJ.fields.NumField;

import static org.openforis.collect.persistence.jooq.tables.OfcTaxon.OFC_TAXON;
import static org.openforis.collect.persistence.jooq.tables.OfcTaxonVernacularName.OFC_TAXON_VERNACULAR_NAME;
import static org.openforis.collect.persistence.jooq.tables.OfcTaxonomy.OFC_TAXONOMY;
import static org.openforis.collect.persistence.jooq.tables.OfcRecord.OFC_RECORD;

import static org.openforis.collect.persistence.jooq.Sequences.OFC_TAXON_ID_SEQ;
import static org.openforis.collect.persistence.jooq.Sequences.OFC_TAXON_VERNACULAR_NAME_ID_SEQ;

/*
 * @author Wibowo, Eko
 * NOTE : this small utility is designed to import DBFs of Indonesia Mofor species into Collect. 
 * It just use getJooqFactory from taxonDao, which must not be like that
 * But to implement a temporal function like this inside a taxonManager, will add a useless complexity
 * So, I just let there is compilation error here. To fix it, just change visibility of getJooqFactory into public
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "/ImportDbf-context.xml" })
@TransactionConfiguration(defaultRollback = false)
public class ImportDbf {
	@Autowired
	private TaxonomyDao taxonomyDao;

	@Autowired
	private TaxonDao taxonDao;

	@Autowired
	private TaxonVernacularNameDao taxonVernacularNameDao;

	@Autowired
	private FactoryDao factoryDao;
	
	@Autowired
	private SurveyManager surveyManager;
	
	@Autowired
	private RecordDao recordDao;
	
	@Autowired
	private UserManager userManager;

	@Test
	public void testImportCluster() throws IOException,
			URISyntaxException {
		URI uri = new URI("file:///E:/DBF/cluster");//URI uri = ClassLoader.getSystemResource("cluster").toURI();
		File dir = new File(uri);

		String[] children = dir.list();
		if (children == null) {
			throw new IOException("Empty or non existing " + uri);

		}

		FileFilter fileFilter = new FileFilter() {
			public boolean accept(File file) {
				return file.isDirectory();
			}
		};

		FilenameFilter fileFilterDbf = new FilenameFilter() {
			public boolean accept(File dir, String name) {
				return name.endsWith("DBF");
			}
		};
		
		DialectAwareJooqFactory jf = factoryDao.getJooqFactory();
		jf.delete(OFC_RECORD).where(OFC_RECORD.CREATED_BY_ID.equal(1)).execute();
		
		
		User user = userManager.loadByUserName("eko");
		File[] files = dir.listFiles(fileFilter);
		System.out.println("Starting at "  + new Date());
		System.out.println("Working with " + files.length + " folder");
		for (File f : files) { // BPKH1_Medan
			System.out.println("Folder " + f.getPath());
			File[] files2 = f.listFiles(fileFilter);
			System.out.println("Working with " + files2.length + " subfolder");
			for (File f2 : files2)
			{
				System.out.println("\tSubfolder " + f2.getPath());
				try {
					processNaturalForest(f2, user);
					processPermanentPlotA(f2, user);
					processPermanentPlotB(f2, user);
				} catch (xBaseJException e) {
					e.printStackTrace();
					continue;
				}
			}
		}
		System.out.println("Ended at"  + new Date());
	}

	
	

	private void processPermanentPlotB(File folderPath, User user) throws xBaseJException, IOException {
		System.out.println("\t\tPermanent Plot B");
		DBF dbf1 = new DBF(folderPath.getPath() + "\\" + "RT7(47).DBF");		
		for (int i = 1; i <= dbf1.getRecordCount(); i++) {
			dbf1.read();
			
			HashMap<String, Object> result = prepareCluster(dbf1, user);
			Entity cluster = (Entity) result.get("cluster");
			String hectarePlot = (String) result.get("tract");//for plat A, tract is hectare plot
			String recordUnit = (String) result.get("subplot");//record unit
			String control = (String) result.get("control");
			String year = (String) result.get("year");
			String clusterKey = (String) result.get("clusterKey");
			String smallOrBig = (String) result.get("smallOrBig");			
			CollectRecord record = (CollectRecord) result.get("record");
			
			Entity permanent_plot_b = cluster.addEntity("permanent_plot_b");
			addDouble(permanent_plot_b, "sector", dbf1, "SECTPB");
			addDouble(permanent_plot_b, "segment_dist", dbf1, "DISTPB");
			
			//keys for permanent plot a
			permanent_plot_b.addValue("control", safeInt(control));
			permanent_plot_b.addValue("hectare_plot", safeDouble(hectarePlot));//TOFIX : this should be integer! And the IDM should be updated too!
			permanent_plot_b.addValue("record_unit", safeInt(recordUnit));
			if("0".equals(smallOrBig) || "1".equals(smallOrBig)) {
				permanent_plot_b.addValue("part", safeInt(smallOrBig)); //large part
			} else {
				permanent_plot_b.addValue("smallpart", safeInt(smallOrBig));
			}
			
			addDouble(permanent_plot_b, "square_5x5", dbf1,"SQRSPB");
			
			Entity number_of_records = permanent_plot_b.addEntity("number_of_records");
			addInt(number_of_records, "seedlings", dbf1, "SEEDNOPB");
			addInt(number_of_records, "saplings", dbf1, "SAPNOPB");
			addDouble(number_of_records, "rattan_less_than2point9m", dbf1, "RAT1PB");//TOFIX : should be int??/
			addDouble(number_of_records, "rattan_more_than3point0m", dbf1, "RAT2PB");
			addDouble(number_of_records, "bamboo", dbf1, "BAMPB");
			addDouble(number_of_records, "depth_of_peat_layer", dbf1, "PEATPB");
			addDouble(number_of_records, "depth_of_litter", dbf1, "LITTERPB");
			//non exist depth_of_peath and depth_of_humus in DBFs
			
			Entity a_horizon = permanent_plot_b.addEntity("a_horizon");
			addDouble(a_horizon, "depth", dbf1, "DEPA");
			addDouble(a_horizon, "stones", dbf1, "STONA");
			addInt(a_horizon, "colour", dbf1, "COLA");
			addInt(a_horizon, "water_regime", dbf1, "WATA");
			addInt(a_horizon, "texture", dbf1, "TEXA");
			
			Entity b_horizon= permanent_plot_b.addEntity("b_horizon");
			addDouble(b_horizon, "depth", dbf1, "DEPB");
			addDouble(b_horizon, "stones", dbf1, "STONB");
			addInt(b_horizon, "colour", dbf1, "COLB");
			addInt(b_horizon, "water_regime", dbf1, "WATB");
			addInt(b_horizon, "texture", dbf1, "TEXB");
			//skipping new / reenumeartion 50cm
			
			addInt(permanent_plot_b, "c_horizon", dbf1, "HORC");
			//skipping slope_position
			addInt(permanent_plot_b, "crew_number", dbf1, "CREWPB");
			addCode(permanent_plot_b, "month", dbf1, "MONPB");
			permanent_plot_b.addValue("year", safeInt(year));
			
			
			DBF dbf2 = new DBF(folderPath.getPath() + "\\" + "RT8(48).DBF");
			for(int j = 1; j <= dbf2.getRecordCount();j++)
			{					
				dbf2.read();
				CharField fldCurrentKey = (CharField) dbf2.getField("KEY");
				String currentKey = fldCurrentKey.get();
				if(currentKey.equals(clusterKey))
				{
					Entity plotb_ssr = permanent_plot_b.addEntity("plotb_ssr");
					addText(plotb_ssr, "name_of_species", dbf2, "LOKAL");
					//TOFIX : count is non exist in foxpro, but exist in tally sheet. Should I calculate it?
					addInt(plotb_ssr, "seedlings", dbf2, "SEEDNOP");
					addInt(plotb_ssr, "saplings", dbf2, "SAPNOP");
					addInt(plotb_ssr, "rattan_lte_2point9m", dbf2, "RAT1NOP");
					
					Entity rattan_gte_3m = plotb_ssr.addEntity("rattan_gte_3m");
					Entity s_single = rattan_gte_3m.addEntity("s_single");
					addInt(s_single, "stems", dbf2, "RAT2NOP");
					addDouble(s_single, "d_max", dbf2, "RAT2DMXP");
					
					Entity c_cluster = rattan_gte_3m.addEntity("c_cluster");
					addDouble(c_cluster,"d_min",dbf2,"RAT2DMNP");
					addDouble(c_cluster,"d_avg",dbf2,"RAT2DAVP");
					addDouble(c_cluster,"l_avg",dbf2,"RAT2LP");							
				}
			}
			
			DBF dbf3 = new DBF(folderPath.getPath() + "\\" + "RT9(49).DBF");
			for(int j = 1; j <= dbf3.getRecordCount();j++)
			{					
				dbf3.read();
				CharField fldCurrentKey = (CharField) dbf3.getField("KEY");
				String currentKey = fldCurrentKey.get();
				if(currentKey.equals(clusterKey))
				{
					Entity bamboo = permanent_plot_b.addEntity("bamboo");
					addText(bamboo, "name_of_species", dbf3, "LOKAL");
					Entity no_culm = bamboo.addEntity("no_culm");
					addInt(no_culm,"one_year", dbf3, "NO1YRPB");
					addInt(no_culm,"two_year", dbf3, "NO2YRPB");
					addInt(no_culm,"total", dbf3, "NOTOTPB");
					addInt(no_culm,"live_stumps", dbf3, "LVSTMPB");
					
					addInt(bamboo, "azimuth_to_bamboo", dbf3, "AZMPB");
					addDouble(bamboo, "horizontal_distance_to_bamboo", dbf3, "DISTPB");	
				}
			}
			
			
			if(record.getId() == null ) {
				recordDao.insert(record);
			} else {
				recordDao.update(record);
			}
		}
		
	}




	private void processPermanentPlotA(File folderPath, User user) throws xBaseJException, IOException {
		System.out.println("\t\tPermanent Plot A");
		DBF dbf1 = new DBF(folderPath.getPath() + "\\" + "RT5(45).DBF");		
		for (int i = 1; i <= dbf1.getRecordCount(); i++) {
			dbf1.read();
			
			HashMap<String, Object> result = prepareCluster(dbf1, user);
			Entity cluster = (Entity) result.get("cluster");
			String hectarePlot = (String) result.get("tract");//for plat A, tract is hectare plot
			String recordUnit = (String) result.get("subplot");//record unit
			String control = (String) result.get("control");
			String year = (String) result.get("year");
			String clusterKey = (String) result.get("clusterKey");
			String smallOrBig = (String) result.get("smallOrBig");
			
			CollectRecord record = (CollectRecord) result.get("record");
			
			Entity permanent_plot_a = cluster.addEntity("permanent_plot_a");
			
			addDouble(permanent_plot_a, "sector", dbf1, "SECTOR");
			addDouble(permanent_plot_a, "segment_dist", dbf1, "DISTANCE");
			
			//keys for permanent plot a
			permanent_plot_a.addValue("control", safeInt(control));
			permanent_plot_a.addValue("hectare_plot", safeDouble(hectarePlot));//TOFIX : this should be integer! And the IDM should be updated too!
			permanent_plot_a.addValue("record_unit", safeInt(recordUnit));
			if("0".equals(smallOrBig) || "1".equals(smallOrBig)) {
				permanent_plot_a.addValue("largepart", safeInt(smallOrBig)); //large part
			} else {
				permanent_plot_a.addValue("part", safeInt(smallOrBig));
			}
			
			addDouble(permanent_plot_a, "square_5x3", dbf1,"SQUARES");
			addCode(permanent_plot_a,"province",dbf1,"PROVINCE");
			addCode(permanent_plot_a,"land_system",dbf1,"LANDSYS");
			addCode(permanent_plot_a,"altitude",dbf1,"ALT");
			addCode(permanent_plot_a,"land_category",dbf1,"LANDUSE");
			addCode(permanent_plot_a,"forest_type",dbf1,"FORTYPE");
			addCode(permanent_plot_a,"stand_condition",dbf1,"STAND");
			addInt(permanent_plot_a,"logging_year", dbf1, "YRLOG");
			addCode(permanent_plot_a,"terrain",dbf1,"TERRAIN");
			addCode(permanent_plot_a,"slope",dbf1,"SLOPE");
			addCode(permanent_plot_a,"aspect",dbf1,"ASPECT");
			addInt(permanent_plot_a, "tp_recorded", dbf1, "NOTREES");
			addInt(permanent_plot_a, "crew_no", dbf1, "CREWNO");
			addCode(permanent_plot_a,"month",dbf1, "MONTHIN");
			permanent_plot_a.addValue("year", safeInt(year));
			
			DBF dbf2 = new DBF(folderPath.getPath() + "\\" + "RT6(46).DBF");
			for(int j = 1; j <= dbf2.getRecordCount();j++)
			{					
				dbf2.read();
				CharField fldCurrentKey = (CharField) dbf2.getField("KEY");
				String currentKey = fldCurrentKey.get();
				if(currentKey.equals(clusterKey))
				{
					Entity plota_enum = permanent_plot_a.addEntity("plota_enum");
					addText(plota_enum, "name_of_species", dbf2, "LOKAL");
					addDouble(plota_enum, "dbb_or_b", dbf2, "DBHP");
					addInt(plota_enum, "damage", dbf2, "DAMAGEP");
					addInt(plota_enum, "azimuth_to_tree", dbf2, "AZIM");
					addDouble(plota_enum, "horizontal_distance_to_tree", dbf2, "DISTP");
					
					Entity trees_higher_than_20cm = plota_enum.addEntity("trees_higher_than_20cm"); 
					addDouble(trees_higher_than_20cm,"butress_height", dbf2, "BUTHTP"); //TODO : adding blank value?
					addDouble(trees_higher_than_20cm, "d_2point2m_ab", dbf2, "D22");
					addDouble(trees_higher_than_20cm,"bole_height",dbf2, "BOLHTP"); // it should be code
					addDouble(trees_higher_than_20cm, "tree_height", dbf2, "TRHT");
					addInt(trees_higher_than_20cm, "grade", dbf2, "GRADEP");
					addInt(trees_higher_than_20cm, "infestation", dbf2, "INFESTP");
					addInt(trees_higher_than_20cm, "tree_class", dbf2, "TRCL");
					addInt(trees_higher_than_20cm, "crown_class", dbf2, "CRCL");
					addInt(trees_higher_than_20cm, "crown_position", dbf2, "CRPOS");
					
					
					Entity bole_and_tree_height = plota_enum.addEntity("bole_and_tree_height");
					addDouble(bole_and_tree_height,"horizontal_distance", dbf2, "DIST1");
					addDouble(bole_and_tree_height,"height_of_base", dbf2, "BASE1");
					addDouble(bole_and_tree_height, "percent_base", dbf2, "PERBASE1");
					addDouble(bole_and_tree_height, "percent_crown_point", dbf2, "PERCP");
					addDouble(bole_and_tree_height, "percent_top_of_tree", dbf2, "PERTOP");
					
					Entity buttress_and_diameter_above_buttress = plota_enum.addEntity("buttress_and_diameter_above_buttress");
					addDouble(buttress_and_diameter_above_buttress, "horizontal_distance", dbf2, "DIST2");
					addDouble(buttress_and_diameter_above_buttress, "percent_base", dbf2, "PERBASE2");
					addDouble(buttress_and_diameter_above_buttress, "percent_buttress", dbf2, "PERCBUT");
					
					Entity d_02_ab = buttress_and_diameter_above_buttress.addEntity("d_02_ab");
					addDouble(d_02_ab, "full_bars", dbf2, "FB1");
					addDouble(d_02_ab, "quarter_bars", dbf2, "B41");
					
					addDouble(buttress_and_diameter_above_buttress, "percent_2point2m_ab", dbf2, "PERC22");
					
					Entity d_22_ab = buttress_and_diameter_above_buttress.addEntity("d_22_ab");
					addDouble(d_22_ab, "full_bars", dbf2, "FB2");
					addDouble(d_22_ab, "quarter_bars", dbf2, "B42");					
				}
			}
			
			
			if(record.getId() == null ) {
				recordDao.insert(record);
			} else {
				recordDao.update(record);
			}
		}
	}




	private void processNaturalForest(File folderPath, User user) throws xBaseJException, IOException {		
		System.out.println("\t\tNATURAL FOREST");
		DBF dbf1 = new DBF(folderPath.getPath() + "\\" + "RT1.DBF");		
		for (int i = 1; i <= dbf1.getRecordCount(); i++) {
			dbf1.read();
			
			HashMap<String, Object> result = prepareCluster(dbf1, user);
			Entity cluster = (Entity) result.get("cluster");
			String tract = (String) result.get("tract");
			String subplot = (String) result.get("subplot");
			String control = (String) result.get("control");
			String year = (String) result.get("year");
			String clusterKey = (String) result.get("clusterKey");
			CollectRecord record = (CollectRecord) result.get("record");
			String smallOrBig = (String) result.get("smallOrBig");
			
			
			
			Entity nf = cluster.addEntity("natural_forest");
			//keys : what else should be included in keys?
			nf.addValue("tract_no", safeInt(tract));
			nf.addValue("subplot_no", safeInt(subplot));
			
			if("0".equals(smallOrBig) || "1".equals(smallOrBig)) {
				nf.addValue("part", safeInt(smallOrBig)); //large part 
			} else {
				nf.addValue("smallpart", safeInt(smallOrBig));//small part
			}
			
			//do this by the contents of the old foxpro fields
			addDouble(nf, "sector", dbf1, "SECTOR");
			addDouble(nf, "segment_dist", dbf1, "DISTANCE");
			
			nf.addValue("control", safeInt(control));
			
			//?Square
			addCode(nf,"province",dbf1,"PROVINCE");
			addCode(nf,"land_system",dbf1,"LANDSYS");
			addCode(nf,"altitude",dbf1,"ALT");
			addCode(nf,"land_category",dbf1,"LANDUSE");
			addCode(nf,"forest_type",dbf1,"FORTYPE");
			addCode(nf,"stand_condition",dbf1,"STAND");
			addInt(nf,"logging_year", dbf1, "YRLOG");
			addCode(nf,"terrain",dbf1,"TERRAIN");
			addCode(nf,"slope",dbf1,"SLOPE");
			addCode(nf,"aspect",dbf1,"ASPECT");
			
			Entity recordCount = nf.addEntity("record_count");
			addInt(recordCount, "trees_poles",dbf1, "NOTREES");
			addInt(recordCount,"seedlings", dbf1, "NOSEED");
			addInt(recordCount,"saplings", dbf1, "NOSAP");
			addInt(recordCount,"sm_rattan", dbf1, "NORAT1");
			addInt(recordCount,"lg_rattan", dbf1, "NORAT2");
			
			addInt(nf, "crew_no", dbf1, "CREWNO");
			addCode(nf,"month",dbf1, "MONTHIN");
			nf.addValue("year", safeInt(year));
			
			
			DBF dbf2 = new DBF(folderPath.getPath() + "\\" + "RT2.DBF");
			for(int j = 1; j <= dbf2.getRecordCount();j++)
			{					
				dbf2.read();
				CharField fldCurrentKey = (CharField) dbf2.getField("KEY");
				String currentKey = fldCurrentKey.get();
				if(currentKey.equals(clusterKey))
				{
					Entity tp = nf.addEntity("tp");
					addText(tp, "species_name", dbf2, "LOKAL");
					addDouble(tp, "diameter", dbf2, "DBH");
					addInt(tp, "damage", dbf2, "DAMAGE");
					
					Entity lg_trees = tp.addEntity("lg_trees");
					//di IDM ada tree_height, tapi disiniga ada. 
					addDouble(lg_trees,"buttress_height", dbf2, "BUTHGT"); //TODO : adding blank value?
					addDouble(lg_trees, "bole_height", dbf2, "BOLHGT");
					addInt(lg_trees,"grade",dbf2, "GRADE"); // it should be code
					addInt(lg_trees, "infestation", dbf2, "INFEST");
					
					Entity bole_height = tp.addEntity("bole_height");
					addDouble(bole_height,"horizontal_distance", dbf2, "DIST1");
					addDouble(bole_height,"base_height", dbf2, "BASE1");
					addDouble(bole_height, "percent_base", dbf2, "PERBASE1");
					addDouble(bole_height, "percent_crown_point", dbf2, "PERCP");
					
					Entity buttress = tp.addEntity("buttress");
					addDouble(buttress, "horizontal_distance", dbf2, "DIST2");
					addDouble(buttress, "percent_base", dbf2, "PERBASE2");
					addDouble(buttress, "percent_buttress", dbf2, "PERCBUT");
					Entity dab = tp.addEntity("dab");
					addDouble(dab, "full_bars", dbf2, "FB1");
					addDouble(dab, "quarter_bars", dbf2, "B41");
				}
			}
			
			DBF dbf3 = new DBF(folderPath.getPath() + "\\" + "RT4.DBF");
			for(int k=1;k<=dbf3.getRecordCount();k++)
			{
				dbf3.read();
				CharField fldCurrentKey = (CharField) dbf3.getField("KEY");
				String currentKey = fldCurrentKey.get();
				if(currentKey.equals(clusterKey))
				{
					Entity ssr = nf.addEntity("ssr");
					addText(ssr, "species_name", dbf3, "LOKAL");
					//ada count disini, tapi di foxpro g d. Di tally sheet ada
					addInt(ssr, "seedlings",dbf3, "SEEDNO");
					addInt(ssr, "saplings", dbf3, "SAPNO");
					addInt(ssr, "sm_rattan", dbf3, "RAT1NO");
					
					Entity lg_rattan = ssr.addEntity("lg_rattan");
					addInt(lg_rattan, "stems", dbf3, "RAT2NO");
					addDouble(lg_rattan, "max_diameter", dbf3, "RAT2DMX");
					addDouble(lg_rattan, "min_diameter", dbf3, "RAT2DMN");
					addDouble(lg_rattan, "avg_diameter", dbf3, "RAT2DAV");
					addDouble(lg_rattan, "avg_length", dbf3, "RAT2L");					
				}
			}
			
			
			if(record.getId() == null ) {
				recordDao.insert(record);
			} else {
				recordDao.update(record);
			}								
		}	
		
	}

	private HashMap<String, Object> prepareCluster(DBF dbf1, User user) throws ArrayIndexOutOfBoundsException, xBaseJException
	{
		HashMap<String, Object> result = new HashMap<String, Object>(); 
		CollectRecord record;
		CharField fldKey = (CharField) dbf1.getField("KEY");
		String clusterKey = fldKey.get().toString();					
		String utmZone = clusterKey.substring(0,2);
		String easting = clusterKey.substring(2,5);
		String northing = clusterKey.substring(5,9);
		String year = generateYear(clusterKey.substring(9, 11));
		String control = clusterKey.substring(11,12);
		String tract = clusterKey.substring(12, 13);
		String subplot = clusterKey.substring(13, 15);
		String smallOrBig = clusterKey.substring(15, 16);
		
		CollectSurvey survey = surveyManager.get("idnfi");										
		Entity cluster;
		
		List<CollectRecord> recordList = recordDao.loadSummaries(survey, "cluster", utmZone,easting,northing);
		if(recordList.size()==0)
		{
			System.out.println("\t\tNew cluster, creating : " + clusterKey + " : " + utmZone + " " + easting + " " + northing + " "  + year + " " + control + " " + tract + " " + subplot + " " +smallOrBig);
			record = new CollectRecord(survey, "1.0");
			cluster = record.createRootEntity("cluster");
			cluster.addValue("utm_zone", safeInt(utmZone));
			cluster.addValue("easting", safeInt(easting));
			cluster.addValue("northing", safeInt(northing));
			cluster.addValue("year", safeInt(year));//this is new one, added by me, not in the tally sheet
		}else{
			//System.out.println("Existing cluster, loading : " + clusterKey + " : " + utmZone + " " + easting + " " + northing + " "  + year + " " + control + " " + tract + " " + subplot + " " +smallOrBig);
			record = recordDao.load(survey, recordList.get(0).getId(), 1);									
			cluster = record.getRootEntity();
			Assert.assertNotNull(cluster);
		}
		
		record.setCreationDate(new Date());
		record.setStep(Step.ENTRY);
		ArrayList<String> keys = new ArrayList<String>();
		keys.add(utmZone);
		keys.add(easting);
		keys.add(northing);
		record.setCreatedBy(user);
		record.setModifiedBy(user);
		record.setModifiedDate(new Date());
		record.setRootEntityKeyValues(keys);
		
		result.put("cluster", cluster);
		result.put("tract", tract);
		result.put("subplot", subplot);
		result.put("control", control);
		result.put("year", year);
		result.put("clusterKey", clusterKey);
		result.put("record", record);
		result.put("smallOrBig", smallOrBig);
		
		return result; 
	}
	
	private void addDouble(Entity entity, String collectField, DBF dbfFile, String dbField) throws ArrayIndexOutOfBoundsException, xBaseJException {
		String strValue = ((NumField) dbfFile.getField(dbField)).get().trim();
		if("0".equals(strValue))
		{
			RealAttribute attr = entity.addValue(collectField, safeDouble("0"));
			//attr.getField(0).setSymbol('*');
			//attr.getField(0).setRemarks("Zero value specified");
			
		} else if("".equals(strValue))
		{	
			RealAttribute attr = entity.addValue(collectField, (Double) null);
			attr.getField(0).setSymbol('*');
			attr.getField(0).setRemarks("Empty value specified");
		}
		else if(!"".equals(strValue))
		{
			try { 
				entity.addValue(collectField, safeDouble(strValue));
			} catch (Exception e)
			{
				e.printStackTrace();
				entity.addValue(collectField, safeDouble("666"));
			}
		}
	}



	private void addText(Entity entity, String collectField, DBF dbfFile, String dbField) throws ArrayIndexOutOfBoundsException, xBaseJException {
		String strValue = ((CharField) dbfFile.getField(dbField)).get().trim();
		entity.addValue(collectField, strValue);
	}



	private void addInt(Entity entity, String collectField, DBF dbfFile, String dbField) throws NumberFormatException, ArrayIndexOutOfBoundsException, xBaseJException {
		String strValue;
		try 
		{
			strValue = ((NumField) dbfFile.getField(dbField)).get().trim();
		}catch(ClassCastException ex)
		{
			strValue = ((CharField) dbfFile.getField(dbField)).get().trim(); // there are cases where the int value in DBFs are stored as text
		}
		
		if("0".equals(strValue))
		{
			IntegerAttribute attr = entity.addValue(collectField, safeInt("0"));
			//attr.getField(0).setSymbol('*');
			//attr.getField(0).setRemarks("Zero value specified");
			
		} else if("".equals(strValue))
		{	
			IntegerAttribute attr = entity.addValue(collectField, (Integer) null);
			attr.getField(0).setSymbol('*');
			attr.getField(0).setRemarks("Empty value specified");
		}
		else if(!"".equals(strValue))
		{
			try {
				entity.addValue(collectField, safeInt(strValue));
			} catch (Exception e)
			{
				e.printStackTrace();
				entity.addValue(collectField, safeInt("666"));
			}
		}
	}

	private void addCode (Entity entity, String collectField, DBF dbfFile, String dbField) throws ArrayIndexOutOfBoundsException, xBaseJException {
		String strValue = ((NumField) dbfFile.getField(dbField)).get().trim();
		if(!"".equals(strValue))
		{
			entity.addValue(collectField, new Code(strValue));
		}
	}

	private double getDouble(DBF dbfFile, String field) throws xBaseJException {
		return safeDouble((((NumField) dbfFile.getField(field)).get().trim()));
	}

	private double safeDouble(String string) {
		// TODO Auto-generated method stub
	try{
			return Double.parseDouble(string);
		}catch(Exception e){
			e.printStackTrace();
			return 666.0;
		}
		
	}




	private String generateYear(String twoDigitYear) {
		int year;
		String result;
		try {
			year = safeInt(twoDigitYear);
			if(year<11){
				result = "19" + twoDigitYear;//
			}else{
				result = "20" + twoDigitYear;//11
			}
		} catch(Exception e)
		{
			e.printStackTrace();
			result = "666";
		}
		return result;
	}

	private int safeInt(String twoDigitYear) {
		// TODO Auto-generated method stub
		try{			return Integer.parseInt(twoDigitYear);
			
			
		}catch(Exception e){
			return 666;
		}
		
	}




	protected void clearData(Factory jf) {
		jf.delete(OFC_TAXON_VERNACULAR_NAME).execute();
		jf.delete(OFC_TAXON).where(OFC_TAXON.PARENT_ID.isNotNull()).execute();
		jf.delete(OFC_TAXON).execute();
		jf.delete(OFC_TAXONOMY).execute();
	}

	// @Test
	public void testClearData() {
		clearData(factoryDao.getJooqFactory());
	}

	/*
	// @Test
	public void testImportSpecies() throws xBaseJException, IOException {
		String provinces[] = { "species/region/irian.dbf",
				"species/region/kalbar.dbf", "species/region/kalimant.dbf",
				"species/region/kalsel.dbf", "species/region/kaltim.dbf",
				"species/region/maluku.dbf", "species/region/sulawesi.dbf",
				"species/region/sumatera.dbf", "species/region/timor.dbf" };
		Factory jf = factoryDao.getJooqFactory();
		clearData(jf);

		// prepare taxonomy
		Taxonomy taxonomy;
		taxonomy = taxonomyDao.load("mofor_species");
		if (taxonomy == null) {
			taxonomy = new Taxonomy();
			taxonomy.setName("mofor_species");
			taxonomyDao.insert(taxonomy);
		}

		// master species
		URL dbf = ClassLoader.getSystemResource("species/species.dbf");
		DBF dbfFile = new DBF(dbf.getPath());
		Assert.assertNotNull(dbfFile.getName());

		NumField fldNfi = (NumField) dbfFile.getField("NFI");
		CharField fldKode = (CharField) dbfFile.getField("KODE");
		CharField fldFamili = (CharField) dbfFile.getField("FAMILI");
		CharField fldGenus = (CharField) dbfFile.getField("GENUS");
		CharField fldSpesies = (CharField) dbfFile.getField("SPESIES");

		// in this species import task, systemId is the same as taxonId
		int taxonId, familyId, genusId;
		Taxon famili, genus, spesies;
		for (int i = 1; i <= dbfFile.getRecordCount(); i++) {
			dbfFile.read();
			if (fldKode.get().equals(null) || "".equals(fldKode.get()))
				continue;

			// family. removed duplication
			famili = new Taxon();
			Record record = jf
					.select(OFC_TAXON.ID)
					.from(OFC_TAXON)
					.where(OFC_TAXON.SCIENTIFIC_NAME.equalIgnoreCase(fldFamili
							.get().toString()))
					.and(OFC_TAXON.TAXON_RANK.equal("family")).fetchOne();
			if (record == null) {
				taxonId = jf.nextval(OFC_TAXON_ID_SEQ).intValue();
				familyId = taxonId;
				famili.setSystemId(taxonId);
				famili.setTaxonId(taxonId);
				famili.setCode("fam_" + fldNfi.get().toString());
				famili.setScientificName(fldFamili.get());
				famili.setTaxonomicRank("family");
				famili.setStep(9);
				famili.setTaxonomyId(taxonomy.getId());
				famili.setParentId(null);
				taxonDao.insert(famili);
			} else {
				familyId = record.getValueAsInteger(OFC_TAXON.ID);
			}

			// genus. Remove duplication
			genus = new Taxon();
			record = jf
					.select(OFC_TAXON.ID)
					.from(OFC_TAXON)
					.where(OFC_TAXON.SCIENTIFIC_NAME.equalIgnoreCase(fldGenus
							.get().toString()))
					.and(OFC_TAXON.TAXON_RANK.equal("genus")).fetchOne();
			if (record == null) {
				taxonId = jf.nextval(OFC_TAXON_ID_SEQ).intValue();
				genusId = taxonId;
				genus.setSystemId(taxonId);
				genus.setTaxonId(taxonId);
				genus.setCode("gen_" + fldNfi.get().toString());
				genus.setScientificName(fldGenus.get().toString());
				genus.setTaxonomicRank("genus");
				genus.setStep(9);
				genus.setTaxonomyId(taxonomy.getId());
				genus.setParentId(familyId);
				taxonDao.insert(genus);
			} else {
				genusId = record.getValueAsInteger(OFC_TAXON.ID);
			}

			// spesies. Duplication allowed, because in the data, there is the
			// same species name with different genus and family name
			spesies = new Taxon();
			taxonId = jf.nextval(OFC_TAXON_ID_SEQ).intValue();
			spesies.setTaxonId(taxonId);
			spesies.setCode(fldNfi.get().toString());
			spesies.setScientificName(fldSpesies.get().toString());
			spesies.setTaxonomicRank("species");
			spesies.setStep(9);
			spesies.setTaxonomyId(taxonomy.getId());
			spesies.setParentId(genusId);
			taxonDao.insert(spesies);
		}

		// each provinces
		for (int i = 0; i < provinces.length; i++) {
			dbf = ClassLoader.getSystemResource(provinces[i]);
			dbfFile = new DBF(dbf.getPath());
			System.out.println(dbf.getPath());

			NumField fldNfiVn = (NumField) dbfFile.getField("NFI");
			CharField fldTempatVn = (CharField) dbfFile.getField("TEMPAT");
			CharField fldNamaVn = (CharField) dbfFile.getField("NAMA");
			CharField fldFamilyVn = (CharField) dbfFile.getField("FAMILY");
			CharField fldGenusVn = (CharField) dbfFile.getField("GENUS");

			for (int j = 1; j <= dbfFile.getRecordCount(); j++) {

				dbfFile.read();
				Record r = jf
						.select(OFC_TAXON.ID)
						.from(OFC_TAXON)
						.where(OFC_TAXON.CODE.equalIgnoreCase(fldNfiVn.get()
								.toString())).fetchOne();
				if (r == null) // invalid data case of a VN refer to inexisting
								// Species
				{
					System.out.println("V.n : " + fldNamaVn.get().toString()
							+ " refer to unexisting Species NFI Code : "
							+ fldNfiVn.get().toString());
					continue;
				}
				taxonId = r.getValueAsInteger(OFC_TAXON.ID);
				TaxonVernacularName vn = new TaxonVernacularName();

				r = jf.select(OFC_TAXON_VERNACULAR_NAME.VERNACULAR_NAME)
						.from(OFC_TAXON_VERNACULAR_NAME)
						.where(OFC_TAXON_VERNACULAR_NAME.VERNACULAR_NAME
								.equalIgnoreCase(fldNamaVn.get().toString()))
						.fetchOne();
				String provinceCode, vnName;
				if (r == null) {
					vn.setId(jf.nextval(OFC_TAXON_VERNACULAR_NAME_ID_SEQ)
							.intValue());
					vn.setTaxonSystemId(taxonId);
					vnName = WordUtils.capitalize(fldNamaVn.get().toString()
							.toLowerCase());
					vn.setVernacularName(vnName);
					vn.setStep(9);
					vn.setLanguageCode("id");
					List<String> qualifier = new ArrayList<String>();
					provinceCode = fldTempatVn.get().toString().trim();
					if (provinceCode.equals("")) {
						System.out
								.println("No province code for v.n " + vnName);
					} else {
						qualifier.add("" + safeInt(provinceCode));// remove
																			// left
																			// padding
																			// zero,
																			// e.g
																			// 06
						vn.setQualifiers(qualifier);
					}
					taxonVernacularNameDao.insert(vn);
				}
			}

		}
	}*/

}
