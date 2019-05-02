module SearchHelper
  EVERYTHING = "*"
  PER_PAGE = 10

  def strip_empty_values(array)
    array.delete_if {|a| a.nil? || a.strip.empty? || a.strip == "all"} if array
  end

  def metadata(results)
    {
      hits: results.total_count,
      perPage: results.per_page,
      page: results.current_page,
      totalPages: results.total_pages
    }
  end
end