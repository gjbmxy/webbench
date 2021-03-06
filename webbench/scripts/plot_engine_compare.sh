#!/bin/bash
#
# Copyright (c) <2011>, <NetEase Corporation>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 3. Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# @AUTHOR "LI WEIZHAO"
# @CONTACT "rickylee86#gmail.com"
# @DATE "2012-11-17"
#

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./scripts/gnuplot/lib
export PATH=$PATH:./scripts/gnuplot/bin

INFILE="tps.txt"
OUTDIR="/tmp/"
PLOTFILE="plot.data"

while getopts "i:o:" opt; do
	case $opt in
		i)
			INFILE=$OPTARG
			;;
		o)
			OUTDIR=$OPTARG
			;;
	esac
done
if [ ! -f "$INFILE" ]; then
	echo "$INFILE does not exist."
	exit 1
fi

make_directories()
{
	OUTDIR=${1}
	mkdir -p ${OUTDIR}
}

make_directories $OUTDIR


#
# Plot the ntse physical read information.
#
NAME="ntse_innodb_compare"
INPUT_FILE="tps.txt"
PNG_FILE="${NAME}.png"
echo "plot \"tps.txt\" using 1:2 title \"ntse with mms\" with linespoints, \
\"tps.txt\" using 1:3 title \"ntse no mms\" with linespoints, \
\"tps.txt\" using 1:4 title \"innodb\" with linespoints, \
\"tps.txt\" using 1:5 title \"innodb with memcached\" with linespoints" > ${OUTDIR}/${PLOTFILE}
echo "set title \"NTSE and innodb comparision\"" >> ${OUTDIR}/${PLOTFILE}
echo "set grid xtics ytics" >> ${OUTDIR}/${PLOTFILE}
echo "set xlabel \"memory(%)\"" >> ${OUTDIR}/${PLOTFILE}
echo "set ylabel \"tps\"" >> ${OUTDIR}/${PLOTFILE}
echo "set term png small" >> ${OUTDIR}/${PLOTFILE}
echo "set output \"${PNG_FILE}\"" >> ${OUTDIR}/${PLOTFILE}
#echo "set xrange [0:]" >> ${OUTDIR}/${PLOTFILE}
echo "set yrange [0:]" >> ${OUTDIR}/${PLOTFILE}
echo "replot" >> ${OUTDIR}/${PLOTFILE}
gnuplot ${OUTDIR}/${PLOTFILE}
rm ${OUTDIR}/${PLOTFILE} > /dev/null 2>&1
#rm ${OUTDIR}/tps.txt > /dev/null 2>&1	
