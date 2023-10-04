# frozen_string_literal: true

class Error < StandardError; end
class UnSelectable < StandardError; end

# Selectable: Help load classes and modules for a specific use case based
# on user input
#
# Attributes:
#   namespace: A module or class namespace to load
#   downcase: Whether or not to downcase inputs.
#     Default: true
class Selectable
  VERSION = "0.1.1"

  attr_reader :namespace, :downcase

  def initialize(namespace: nil, downcase: true)
    @namespace = namespace
    @downcase = downcase
  end

  # Returns an array of selectable modules and classes from the namespace
  # provided
  #
  # For convenience, it will coerce
  def selectable
    return @selectable if @selectable

    selector_data = {}
    namespace.constants.each do |c|
      selector = namespace.const_get(c)
      next unless can_be_selected(selector)

      s = selector.selectable_for
      raise Error, "selectable_for must be an array in #{selector}" unless s.is_a?(Array)

      s.each { |x| x.downcase! if can_downcase(x) }
      selector_data[selector] = s
    end
    @selectable = selector_data
  end

  def selectors
    selectable.values.flatten
  end

  def selectable?(object)
    object.downcase! if can_downcase(object)
    return true if selectors.include?(object)

    false
  end

  def for(thing)
    selectable.each do |obj, values|
      thing.downcase! if can_downcase(thing)
      return obj if values.include?(thing)
    end

    raise UnSelectable, "#{thing} is unselectable"
  end

  private

  def can_be_selected(obj)
    (obj.is_a?(Module) || obj.is_a?(Class)) && obj.respond_to?(:selectable_for)
  end

  def can_downcase(obj)
    downcase && obj.respond_to?(:downcase) && !obj.frozen?
  end
end
