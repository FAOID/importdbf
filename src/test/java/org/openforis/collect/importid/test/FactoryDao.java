package org.openforis.collect.importid.test;

import org.openforis.collect.persistence.jooq.DialectAwareJooqFactory;
import org.openforis.collect.persistence.jooq.JooqDaoSupport;

/*
 * @author E. Wibowo
 * I just need a JooqFactory... 
 */
public class FactoryDao extends JooqDaoSupport {

	@Override
	public DialectAwareJooqFactory getJooqFactory() {
		return super.getJooqFactory();
	}
}
