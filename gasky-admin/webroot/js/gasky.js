$(function() {
  // Initialize data table with full controls
  if ($('.all-controls').length) {
    $('.all-controls').DataTable({});
  }
  
  // Initialize data table with pagination only
  if ($('.only-paginate').length) {
    $('.only-paginate').DataTable({
      lengthChange: false,
      pageLength: 20,
      searching: false
    });
  }
  
  // Repeatable coordinate fields
  if ($('#form-coordinates').length) {
    var rowReference = $('#form-coordinates > .row')[0].outerHTML;
        
    $('#add-coordinate').click(function(e) {
      e.preventDefault();
      $('#form-coordinates').append(rowReference);
      $('.coordinate-pair').last().find('input').removeAttr('value');
    });
  }
  
  // Date input masking
  if ($('#expires').length) {
    $('#expires').inputmask('mm/dd/yyyy', {placeholder: 'mm/dd/yyyy'});
  }
  
  // Order settling display
  if ($('span#total').length) {
    calculateTotal();
    $('#gallons, #price-per-gallon').change(function() {
      console.log('change');
      calculateTotal();
    });
  }
  
  function calculateTotal() {
    var gallons = $('#gallons').val();
    var pricePerGallon = $('#price-per-gallon').val();
    var gasTotal = +((gallons * pricePerGallon).toFixed(2));
    var deliveryFee = +($('#delivery-fee').val());
    var total = gasTotal + deliveryFee;

    if ($('span#discount').length) {
      if ($('span#discount').attr('data-type') === 'dollar') {
        var discount = +($('span#discount').attr('data-amount'));
        total = total - discount;
      }
      
      if ($('span#discount').attr('data-type') === 'percent') {
        var percentage = +($('span#discount').attr('data-amount'));
        var discount = +((total / 100 * percentage).toFixed(2));
        total = total - discount;
      }
    }
    
    $('#gas-total').val(gasTotal.toFixed(2));
    $('span#total').html(total.toFixed(2));
    
    return total;
  }
});