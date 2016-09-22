

class T
  def self.get(url, params)
    RestClient.get  url, {:params => params}
  end
end