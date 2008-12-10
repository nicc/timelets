
function switch_contract_type(contract_type) {
  switch (contract_type){
    case 'RateContract':
      $('rate-contract-fields').show();
      $('point-contract-fields').hide();
      $$('.rate-contract-field').each(function(f) { f.enable(); });
      $$('.point-contract-field').each(function(f) { f.disable(); });
      break;
    case 'PointContract':
      $('rate-contract-fields').hide();
      $('point-contract-fields').show();
      $$('.rate-contract-field').each(function(f) { f.disable(); });
      $$('.point-contract-field').each(function(f) { f.enable(); });
      break;
    default:
      $('rate-contract-fields').hide();
      $('point-contract-fields').hide();
      $$('.rate-contract-field').each(function(f) { f.disable(); });
      $$('.point-contract-field').each(function(f) { f.disable();});
  }
}
