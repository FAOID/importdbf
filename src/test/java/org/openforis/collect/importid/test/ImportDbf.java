package org.openforis.collect.importid.test;

import static org.openforis.collect.persistence.jooq.Sequences.OFC_TAXON_ID_SEQ;

import java.io.IOException;
import java.net.URL;

import junit.framework.Assert;

import org.jooq.impl.Factory;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.openforis.collect.persistence.TaxonDao;
import org.openforis.collect.persistence.TaxonVernacularNameDao;
import org.openforis.collect.persistence.TaxonomyDao;
import org.openforis.idm.model.species.Taxon;
import org.openforis.idm.model.species.Taxonomy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.xBaseJ.DBF;
import org.xBaseJ.xBaseJException;
import org.xBaseJ.fields.CharField;

/*
 * @author Wibowo, Eko
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

	// @Test
	public void testImportCluster() throws xBaseJException, IOException {
		URL dbf = ClassLoader.getSystemResource("cluster/sample/RT1.DBF");
		DBF dbfFile = new DBF(dbf.getPath());
		Assert.assertNotNull(dbfFile.getName());
		/*
		 * KEY is 4717003009302060 47 = zone 170 = easting 0300 = northing 93 =
		 * inventory year 0 = control number 2 = track number 06 = sub plot
		 * number 0 = small or big part
		 */
		CharField key = (CharField) dbfFile.getField("KEY");
		for (int i = 1; i <= dbfFile.getRecordCount(); i++) {
			dbfFile.read();
			System.out.println(i + ":" + key.get());
		}
	}

	@Test
	public void testImportSpecies() throws xBaseJException, IOException {
		// find first
		Taxonomy taxonomy;
		taxonomy = taxonomyDao.load("mofor_species");
		if (taxonomy == null) {
			taxonomy = new Taxonomy();
			taxonomy.setName("mofor_species");
			taxonomyDao.insert(taxonomy);
		}

		URL dbf = ClassLoader.getSystemResource("species/species.dbf");
		DBF dbfFile = new DBF(dbf.getPath());
		Assert.assertNotNull(dbfFile.getName());

		CharField fldKode = (CharField) dbfFile.getField("KODE");
		CharField fldFamili = (CharField) dbfFile.getField("FAMILI");
		CharField fldGenus = (CharField) dbfFile.getField("GENUS");
		CharField fldSpesies = (CharField) dbfFile.getField("SPESIES");

		Factory jf = taxonDao.getJooqFactory();
		int taxonId;
		Taxon famili, genus, spesies;
		for (int i = 1; i <= dbfFile.getRecordCount(); i++) {
			dbfFile.read();
			if(fldKode.get().equals(null)|| "".equals(fldKode.get())) continue;

			// family
			famili = new Taxon();
			taxonId = jf.nextval(OFC_TAXON_ID_SEQ).intValue();
			famili.setTaxonId(taxonId);
			famili.setCode(("fam_" + fldFamili.get().substring(0, 3)).toUpperCase());
			famili.setScientificName(fldFamili.get());
			famili.setTaxonomicRank("family");
			famili.setStep(9);
			famili.setTaxonomyId(taxonomy.getId());
			famili.setParentId(null);
			taxonDao.insert(famili);

			// genus
			genus = new Taxon();
			taxonId = jf.nextval(OFC_TAXON_ID_SEQ).intValue();
			genus.setTaxonId(taxonId);
			genus.setCode(("gen_" + fldGenus.get().substring(0, 3)).toUpperCase());
			genus.setScientificName(fldGenus.get().toString());
			genus.setTaxonomicRank("genus");
			genus.setStep(9);
			genus.setTaxonomyId(taxonomy.getId());
			genus.setParentId(famili.getSystemId());
			taxonDao.insert(genus);

			// spesies
			spesies = new Taxon();
			taxonId = jf.nextval(OFC_TAXON_ID_SEQ).intValue();
			spesies.setTaxonId(taxonId);
			spesies.setCode(("spec_" + fldSpesies.get().substring(0, 3)).toUpperCase());
			spesies.setScientificName(fldSpesies.get().toString());
			spesies.setTaxonomicRank("species");
			spesies.setStep(9);
			spesies.setTaxonomyId(taxonomy.getId());
			spesies.setParentId(genus.getSystemId());
			taxonDao.insert(spesies);

		}
	}

}
