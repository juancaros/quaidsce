*! version 1.1.0  18jul2013

program quaidsce_estat

	version 12
	
	if "`e(cmd)'" != "quaidsce" {
		exit 301
	}
	
	gettoken key 0 : 0, parse(", ")
	local lkey = length(`"`key'"')
	
	if `"`key'"' == substr("expenditure", 1, max(3, `lkey')) {
		DoExp `0'
	}
	else if `"`key'"' == substr("uncompensated", 1, max(6, `lkey')) {
		DoUncomp `0'
	}
	else if `"`key'"' == substr("compensated", 1, max(4, `lkey')) {
		DoComp `0'
	}
	else {
		di as error "invalid subcommand `key'"
		exit 321
	}
	
end

program DoExp, rclass

	syntax [anything(name = vlist id = "newvarlist")] [if] [in] 	///
		[, atmeans Stderrs]
	
	marksample touse

	if ("`stderrs'" != "" & "`atmeans'" == "") {
		qui count if `touse'
		if r(N) != 1 {
			di as err			/// 
"may only specify {bf:stderrs} if the selected sample has one observation"
			exit 198
		}
	}
	


end


program DoUncomp, rclass

	syntax [anything(name = vlist id = "newvarlist")] [if] [in]	///
		[, atmeans Stderrs]
	
	marksample touse
	
	if ("`stderrs'" != "" & "`atmeans'" == "") {
		qui count if `touse'
		if r(N) != 1 {
			di as err			/// 
"may only specify {bf:stderrs} if the selected sample has one observation"
			exit 198
		}
	}
	


end

program DoComp, rclass

	syntax [anything(name = vlist id = "newvarlist")] [if] [in] 	///
		[, atmeans Stderrs]

	marksample touse


end

