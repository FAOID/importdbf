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
import java.util.List;

import junit.framework.Assert;

import org.apache.commons.lang3.text.WordUtils;
import org.jooq.Field;
import org.jooq.Record;
import org.jooq.SelectConditionStep;
import org.jooq.impl.Factory;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.openforis.collect.persistence.TaxonDao;
import org.openforis.collect.persistence.TaxonVernacularNameDao;
import org.openforis.collect.persistence.TaxonomyDao;
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

	@Test
	public void testImportCluster() throws IOException,
			URISyntaxException {
		URI uri = ClassLoader.getSystemResource("cluster").toURI();
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
		/*
		 * KEY is 4717003009302060 47 = zone 170 = easting 0300 = northing 93 =
		 * inventory year 0 = control number 2 = track number 06 = sub plot
		 * number 0 = small or big part
		 */
		File[] files = dir.listFiles(fileFilter);
		for (File f : files) { // BPKH1_Medan
			System.out.println("Processing folder " + f.getPath());
			File[] files2 = f.listFiles(fileFilter);
			for (File f2 : files2)
			{
				System.out.println("\tProcessing folder " + f2.getPath());
				String[] dbfs = 
						{ 
						"RT1.DBF", 
						"RT2.DBF",
						"RT4.DBF",
						"RT5(45).DBF",
						"RT6(46).DBF",
						"RT7(47).DBF",
						"RT8(48).DBF",
						//"RT9(49).DBF",
						"RT10.DBF",
						"RT11(61).DBF",
						"RT12(62).DBF",
						"RT13(63).DBF",
						"RT14(64).DBF",
						"RT15.DBF",
						"RT16.DBF",
						"RT17.DBF",
						};
				for (String dbf : dbfs) {
					DBF dbfFile = null;
					try {
						String dbfName= f2.getPath() + "\\" + dbf;
						System.out.println("\t\tProcessing " + dbfName);
						if(dbf.equals("RT1.DBF"))
						{
							
						}
						dbfFile = new DBF(dbfName);
					} catch (xBaseJException e) {
						e.printStackTrace();
						continue;
					}
					
					
					try {
						CharField key = (CharField) dbfFile.getField("KEY");
					} catch (ArrayIndexOutOfBoundsException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (xBaseJException e) {
						// TODO Auto-generated catch block
						System.out.println(e.getMessage());
						continue;
						
					}
					for (int i = 1; i <= dbfFile.getRecordCount(); i++) {
						try {
							dbfFile.read();
						} catch (xBaseJException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						//System.out.println(i + ":" + key.get());
					}
				}
			}
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
						qualifier.add("" + Integer.parseInt(provinceCode));// remove
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

	}

}
