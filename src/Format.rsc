module Format

import util::SimpleBox;
import Syntax;

/*
 * Formatting: transforming QL forms to Box 
 */

str formatQL(start[Form] form) = format(form2box(form));

Box form2box(start[Form] form) = H();


