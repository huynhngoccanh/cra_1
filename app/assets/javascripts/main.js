$(document).ready(function (e) {
  $('#body').on('input propertychange', function() {
    val = $(this).val();
    $.ajax({
      url: '/link_info/index',
      data: { url: val },
      method: 'POST'
    });
  });

  toastr.options = {
  "closeButton": false,
  "debug": false,
  "positionClass": "toast-bottom-right",
  "onclick": null,
  "showDuration": "2000",
  "hideDuration": "1000",
  "timeOut": "3000",
  "extendedTimeOut": "2000",
  "showEasing": "swing",
  "hideEasing": "linear",
  "showMethod": "fadeIn",
  "hideMethod": "fadeOut",
  "closeEasing": "swing"

  }

  $('#my-invoices a').click(function(e) {
    e.preventDefault();
    $(this).tab('show');
  });

});