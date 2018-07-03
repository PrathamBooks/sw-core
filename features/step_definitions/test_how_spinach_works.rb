#class Spinach::Features::TestHowSpinachWorks < Spinach::FeatureSteps
#  step 'I have an empty array' do
#    @array = Array.new
#  end
#
#  step 'I append my first name and my last name to it' do
#    @array += ["John", "Doe"]
#  end
#
#  step 'I pass it to my super-duper method' do
#    @output = capture_output do
#      Greeter.greet(@array)
#    end
#  end
#
#  step 'the output should contain a formal greeting' do
#    @output.must_include "Hello, mr. John Doe"
#  end
#
#  step 'I append only my first name to it' do
#    @array += ["John"]
#  end
#
#  step 'the output should contain a casual greeting' do
#    @output.must_include "Yo, John! Whassup?"
#  end
#
#  private
#
#  def capture_output
#    out = StringIO.new
#    $stdout = out
#    $stderr = out
#    yield
#    $stdout = STDOUT
#    $stderr = STDERR
#    out.string
#  end
#end
#
#module Greeter
#  def self.greet(name)
#    if name.length > 1
#      puts "Hello, mr. #{name.join(' ')}"
#    else
#      puts "Yo, #{name.first}! Whassup?"
#    end
#  end
#end