  def wait_for_ajax
    puts "Waiting for ajax call to get over"
    Timeout.timeout(100) do
      loop until finished_all_ajax_requests?
    end
    puts "ajax call over"
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
