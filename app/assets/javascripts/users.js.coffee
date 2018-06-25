@initPaymentForm=->
  $('#payment_form').submit (event) ->
    $('.submit').attr 'disabled', 'disabled'
    Stripe.createToken {
      number: $('.credit-number').val()
      cvc: $('.credit-security').val()
      exp_month: $('.card-expiry-month').val()
      exp_year: $('.card-expiry-year').val()
    }, stripeResponseHandler
    false

@initCardForm=->
  $('#new-card-modal form').submit (event) ->
    $('.submit').attr 'disabled', 'disabled'
    Stripe.createToken {
      number: $('.credit-number').val()
      cvc: $('.credit-security').val()
      exp_month: $('.card-expiry-month').val()
      exp_year: $('.card-expiry-year').val()
    }, stripeResponseCardHandler
    false

stripeResponseCardHandler = (status, response) ->
  $form = $('#new-card-modal form')
  val = document.getElementById('cvc_number').value

  if response.error
    $form.find('button').prop 'disabled', false
    $form.find('.payment-errors').text(response.error['message']).css 'color', '#F02525'
  else
    if val.length != 3
      $form.find('button').prop 'disabled', false
      $form.find('.payment-errors').text('Please enter 3 digit cvc number').css 'color', '#F02525'
    else
      form$ = $('#new-card-modal form')
      token = response['id']
      form$.append '<input type=\'hidden\' name=\'stripeToken\' value=\'' + token + '\'/>'
      form$.get(0).submit()
  return

stripeResponseHandler = (status, response) ->
  $form = $('#payment_form')
  val = document.getElementById('cvc_number').value

  if response.error
    $form.find('button').prop 'disabled', false
    $form.find('.payment-errors').text(response.error['message']).css 'color', '#F02525'
  else
    if val.length != 3
      $form.find('button').prop 'disabled', false
      $form.find('.payment-errors').text('Please enter 3 digit cvc number').css 'color', '#F02525'
    else
      form$ = $('#payment_form')
      token = response['id']
      form$.append '<input type=\'hidden\' name=\'stripeToken\' value=\'' + token + '\'/>'
      form$.get(0).submit()
  return