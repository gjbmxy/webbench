/**
  * Copyright (c) <2011>, <NetEase Corporation>
  * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 *    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 *    3. Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package com.netease.webbench.blogbench.transaction;

import com.netease.webbench.blogbench.misc.BbTestOptions;
import com.netease.webbench.blogbench.misc.ParameterGenerator;
import com.netease.webbench.blogbench.statis.BlogbenchCounters;
import com.netease.webbench.common.DbOptions;
import com.netease.webbench.common.DbSession;
import com.netease.webbench.common.Util;
import com.netease.webbench.statis.TrxCounter;

/**
 * blogbench transaction
 * @author LI WEIZHAO
 */
public abstract class BbTestTransaction {		
	/* total transaction counter */
	protected TrxCounter totalTrxCounter;
	protected TrxCounter myTrxCounter;
	
	/* percentage of this transaction in all types of transactions */	
	protected int pct;
	
	/* transaction type */
	protected BbTestTrxType trxType;
	
	protected DbSession dbSession;
	protected BbTestOptions bbTestOpt;
	protected DbOptions dbOpt;
	
	public BbTestTransaction(BbTestTransaction another, 
			BlogbenchCounters counters) throws Exception {
		this(another.dbSession, another.bbTestOpt, another.pct, another.trxType,
				counters);
	}
	
	public BbTestTransaction(DbSession dbSession, 
			BbTestOptions bbTestOpt, 
			int pct, 
			BbTestTrxType trxType, 
			BlogbenchCounters counters) throws Exception {
		this.dbSession = dbSession;
		this.bbTestOpt = bbTestOpt;
		this.dbOpt = dbSession.getDbOpt();
		this.pct = pct;
		this.trxType = trxType;
		
		this.totalTrxCounter = counters.getTotalTrxCounter();
		this.myTrxCounter = counters.getSingleTrxCounter(this.trxType);
	}
	
	public final int getPct() {
		return pct;
	}
	
	/**
	 *  create prepared SQL statement
	 * @throws Exception
	 */
	public abstract void prepare() throws Exception;
	
	public void exeTrx(ParameterGenerator paraGen) throws Exception {
		try {
			long before = Util.currentTimeMillis();			
			doExeTrx(paraGen);			
			long after = Util.currentTimeMillis();
			
			long timeWaste = after - before;
			totalTrxCounter.addTrx(timeWaste);
			myTrxCounter.addTrx(timeWaste);
		} catch (Exception e) {
			cleanRes();
			throw e;
		}
	}

	/**
	 * execute this transaction
	 * @param paraGen query parameter generator
	 * @return 
	 */
	protected abstract void doExeTrx(ParameterGenerator paraGen) throws Exception;
	
	public void cleanRes()  throws Exception {}
}
