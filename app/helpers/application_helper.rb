module ApplicationHelper
  def x
    time = Time.now
    8000000.times do |n|
      puts n
    end

    puts "In #{Time.now - time} seconds"
  end

end
