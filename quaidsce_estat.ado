*! version 1.1.0  Sep 2021

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


/// EXPENDITURE ELASTICITY

program DoExp, rclass

	syntax [if] [in] 
	
	marksample touse

/// WRITE HERE THE IF/ELSE WITH THE CORRESPONDING FORMULA FOR THE SHARES USING LOCALS SO WE CAN PREDICT USING MARGINS

/// WRITE HERE THE LOOP FOR THE MARGINS COMMAND INTO TWO MATRICES (elas, se) AND RETURN AS e()

end

/// UNCOMPENSATED PRICE ELASTICITY

program DoUncomp, rclass

	syntax [if] [in] 
	
	marksample touse

	
/// WRITE HERE THE IF/ELSE WITH THE CORRESPONDING FORMULA FOR THE SHARES USING LOCALS SO WE CAN PREDICT USING MARGINS

/// WRITE HERE THE LOOP FOR THE MARGINS COMMAND INTO TWO MATRICES (elas, se) AND RETURN AS e()

end

/// COMPENSATED PRICE ELASTICITY

program DoComp, rclass

	syntax [if] [in] 

	marksample touse

/// WRITE HERE THE IF/ELSE WITH THE CORRESPONDING FORMULA FOR THE SHARES USING LOCALS SO WE CAN PREDICT USING MARGINS
/// NOTE THAT HERE YOU SHOULD CALL THE TWO PROGRAMS ABOVE

/// WRITE HERE THE LOOP FOR THE MARGINS COMMAND INTO TWO MATRICES (elas, se) AND RETURN AS e()

end

