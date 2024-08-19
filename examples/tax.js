var $state = {
  
  hasMaintLoan: false,
  
  hasSoldHouse: false,
  
  privateDebt: 0,
  
  sellingPrice: 0,
  
  valueResidue: 0,
  
  hasBoughtHouse: false,
  
}
function $update(name, value) {
   let change = false;
   let newVal = undefined;
   let div = undefined;
   if (name !== undefined) {
      $state[name] = value;
   }
   do {
     change = false;
     
     div = document.getElementById('hasBoughtHouse_div_31');
     div.style.display = true ? 'block' : 'none'; 
     
     
     div = document.getElementById('hasMaintLoan_div_97');
     div.style.display = true ? 'block' : 'none'; 
     
     
     div = document.getElementById('hasSoldHouse_div_154');
     div.style.display = true ? 'block' : 'none'; 
     
     
     div = document.getElementById('sellingPrice_div_246');
     div.style.display = (true && $state.hasSoldHouse) ? 'block' : 'none'; 
     
     
     div = document.getElementById('privateDebt_div_308');
     div.style.display = (true && $state.hasSoldHouse) ? 'block' : 'none'; 
     
     
     div = document.getElementById('valueResidue_div_375');
     div.style.display = (true && $state.hasSoldHouse) ? 'block' : 'none'; 
     
     newVal = ($state.sellingPrice - $state.privateDebt);
     if (newVal !== $state.valueResidue) {
       let elt = document.getElementById('valueResidue_widget_375');
       $state.valueResidue = newVal;
       
       elt.value = newVal;
       
       change = true;
     }
     
     
   } while (change);
}
