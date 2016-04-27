module GlobalConstants
  
  def GlobalConstants.date(date)
    "#{date.day} #{MONTHS[date.month]} #{date.year}"
  end
  
  def GlobalConstants.dateHour(date)
    "#{date.day} #{MONTHS[date.month]} #{date.year} #{date.strftime('%H:%M')}"
  end
  
  def GlobalConstants.age(birthday)
    now = Time.now.in_time_zone.to_date
    now.year - birthday.year - (birthday.to_date.change(:year => now.year) > now ? 1 : 0)
  end
  
  EVENT_TYPES = ['Eğlence', 'Hobi', 'Gezi & Seyahat', 'Konser & Sanat', 'Yeme & İçme', 'Ders & Okuma', 'Spor' ]
  
end