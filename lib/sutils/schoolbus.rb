module Sutils::Schoolbus

  def next_shuttlebus
  end

  def next_shoolbus
  end

  def next_bus
    # [] => [from, to, schoolbus] date:
    rule = YAML.load File.read(Rails.root.join('config/schoolbus.yml'))

    now = Time.now
    datef = now.strftime("%m%d")
    if (key = rule['special'].keys.bsearch {|x| match_date(x,datef)})
      ary = rule['special'][key]
    elsif now.friday?
      ary = rule['friday']
    elsif now.saturday? or now.sunday?
      ary = rule['weekend']
    else
      ary = empty_ary
    end

    res_time =
      ary['shuttle_sha'].map {|x| gen_time x}.bsearch {|x| x > now}

    if res_time 
      result = "下一次校车的时间是 #{res_time.strftime("%H:%M")} 。"
      if time_diff(now, res_time) < 60
        result = result + "还有#{time_diff(now, res_time)}分钟。"
      end
    else
      result = "看来今天是没有车了。"
    end

    result
  end

  private
    def match_date(x, s)
      if x == s
        return true
      else
        words = x.split("-")
        if words.size == 2 and s >= words[0] and s <= words[1]
          return true
        else
          return false
        end
      end
    end

    def gen_time(x)
      now = Time.now
      Time.mktime(now.year, now.month, now.day, x / 100, x % 100)
    end

    def time_diff(start_time, end_time)
      seconds_diff = (end_time - start_time).to_i.abs
      seconds_diff / 60
    end

    def empty_ary
      {
        'shuttle_sha'=>[],
        'shuttle_sta'=>[],
        'bus_sha'=> [],
        'bus_xue'=>[]
      }
    end

end
