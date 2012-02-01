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
package com.netease.webbench.blogbench.statis;

import java.util.List;

import com.netease.webbench.blogbench.transaction.BbTestTrxType;
import com.netease.webbench.statis.PdfTable;

/**
 * 
 * @author LI WEIZHAO
 *
 */
public class PdfMemHitTable extends PdfTable {
	public PdfMemHitTable(String title, String subTitle) throws Exception {
		super(title, subTitle);		
		float[] widths = {0.18f, 0.14f, 0.14f, 0.14f, 0.142f, 0.14f, 0.14f};
		this.table = PdfTable.createNewTable(BbTestTrxType.TRX_TYPE_NUM, widths);
	}
	
	public void addTextRow(String text, boolean isBold, boolean grayBackground, int colspan) {
		table.addCell(makeCell(text, isBold, grayBackground, colspan));
	}
	
	public void addDataRow(String trxName, List<String> rowData) {
		table.addCell(makeCell(trxName, false, false, 1));
		for (int i = 0; i < rowData.size(); i++) {
			table.addCell(makeCell(rowData.get(i), false, false, 1));
		}
	}
}