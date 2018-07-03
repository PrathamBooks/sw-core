When (/^I follow the confirmation link in the confirmation email$/) do
  ctoken = last_email.body.match(/confirmation_token=[\w\-]+/)
  visit "/users/confirmation?#{ctoken}"
end
