** Nested Logit 
** Restaurant Example

clear
cd "/Users/Andres/Dropbox/CORNELL/Fall 2016/AEM 6700 Economics of Consumer Demand/In Class assignments/4. Restaurant Choice"
*log using nlogit_restaurant.log, replace
*import delimited restaurant_nlogit.xls
*save nlogit_restaurant, replace

use nlogit_restaurant, clear

describe

list family_id restaurant chosen kids rating distance in 1/21, sepby(fam) abbrev(10)

nlogitgen type = restaurant(fast: Freebirds | MamasPizza, ///
    family: CafeEccell | LosNortenos| WingsNmore, fancy: Christophers | MadCows)
nlogittree restaurant type, choice(chosen)
	
nlogitgen type_alt = restaurant(1 2, 3 4 5, 6 7)
nlogittree restaurant type_alt

	
nlogit chosen cost rating distance || type: income kids, base(family) || ///
       restaurant:, noconstant case(family_id)

estat alternatives	   
predict p*
predict condp, condp hlevel(2)
sort family_id type restaurant
list restaurant type chosen p2 p1 condp in 1/14, sepby(family_id) divider

predict xb*, xb
predict iv, iv
list restaurant type chosen xb* iv in 1/14, sepby(family_id) divider

*log close
