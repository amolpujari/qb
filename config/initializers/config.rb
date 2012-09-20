CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]

def CONFIG.[](key)
  key = key.to_s
  #raise "CONFIG['#{key}'] not defined." unless self.has_key? key
  super key
end
