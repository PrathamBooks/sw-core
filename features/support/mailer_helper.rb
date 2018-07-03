def last_email
	Delayed::Worker.new.work_off
	ActionMailer::Base.deliveries.last
end
