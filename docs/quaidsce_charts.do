tw (rcap delta_ll delta_ul rw, horizontal) (scatter rw delta), ylabel(-17 "Nonsugar sweeteners" -16  "Refined Sugar" -15  "Fats & oils" -14  "Sweetened beverages" -13  "Unsweetened beverages" -12  "Snacks" -11  "Sweets" -10  "Legumes & processed FVs" -9  "Vegetables" -8  "Fruits" -7  "Cheese" -6  "|Milk and diary desserts" -5  "Unprocessed meats" -4  "Processed meats" -3  "Breakfast cereals" -2  "Bread" -1  "Starches")

tw (rcap alpha_ll alpha_ul rw, horizontal) (scatter rw alpha) (rcap alpha0_ll alpha0_ul rw, horizontal) (scatter rw alpha0), ylabel(-17 "Nonsugar sweeteners" -16  "Refined Sugar" -15  "Fats & oils" -14  "Sweetened beverages" -13  "Unsweetened beverages" -12  "Snacks" -11  "Sweets" -10  "Legumes & processed FVs" -9  "Vegetables" -8  "Fruits" -7  "Cheese" -6  "|Milk and diary desserts" -5  "Unprocessed meats" -4  "Processed meats" -3  "Breakfast cereals" -2  "Bread" -1  "Starches")

tw (rcap beta_ll beta_ul rw, horizontal) (scatter rw beta) (rcap beta0_ll beta0_ul rw, horizontal) (scatter rw beta0), ylabel(-17 "Nonsugar sweeteners" -16  "Refined Sugar" -15  "Fats & oils" -14  "Sweetened beverages" -13  "Unsweetened beverages" -12  "Snacks" -11  "Sweets" -10  "Legumes & processed FVs" -9  "Vegetables" -8  "Fruits" -7  "Cheese" -6  "|Milk and diary desserts" -5  "Unprocessed meats" -4  "Processed meats" -3  "Breakfast cereals" -2  "Bread" -1  "Starches")

**************

*import data 
use "C:\Users\juanc\OneDrive\Documentos\quaidsce\docs\elas.dta", clear

gen elas_iu=elas_i+1.2*se_elas_i
gen elas_il=elas_i-1.2*se_elas_i
gen nelas_iu=nelas_i+1.9*se_nelas_i
gen nelas_il=nelas_i-1.9*se_nelas_i


tw (rcap elas_iu elas_il rw, horizontal) (scatter rw elas_i) (rcap nelas_iu nelas_il rw, horizontal) (scatter rw nelas_i), ylabel(1 "Starches" 2 "Bread" 3 "Breakfast cereal" 4 "Processed meats" 5 "Unprocessed meats" 6 "Milk and diary" 7 "Cheese" 8 "Fruits" 9 "Vegetables" 10 "Legumes and processed FV" 11 "Sweets" 12 "Snacks" 13 "Unsweetened drinks" 14 "Sweetened drinks" 15 "Fats & oils" 16 "Refined sugar" 17 "Nonsugar sweeteners") 

gen elas_uu=elas_u+1.2*se_elas_u
gen elas_ul=elas_u-1.2*se_elas_u
gen nelas_uu=nelas_u+1.9*se_nelas_u
gen nelas_ul=nelas_u-1.9*se_nelas_u


tw (rcap elas_uu elas_ul rw, horizontal) (scatter rw elas_u) (rcap nelas_uu nelas_ul rw, horizontal) (scatter rw nelas_u), ylabel(1 "Starches" 2 "Bread" 3 "Breakfast cereal" 4 "Processed meats" 5 "Unprocessed meats" 6 "Milk and diary" 7 "Cheese" 8 "Fruits" 9 "Vegetables" 10 "Legumes and processed FV" 11 "Sweets" 12 "Snacks" 13 "Unsweetened drinks" 14 "Sweetened drinks" 15 "Fats & oils" 16 "Refined sugar" 17 "Nonsugar sweeteners") 
