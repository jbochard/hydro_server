# coding: utf-8

class AbstractApplicationExcpetion < Exception
	attr_reader :code

	def initialize(element, code)
    	super(element)
    	@code = code
  	end
end

class NotFoundException < AbstractApplicationExcpetion

	def initialize(element, name=nil)
    	super("#{element} #{name} no encontrado.", 404)
  	end
end
 
class AlreadyExistException < AbstractApplicationExcpetion

	def initialize(element, name=nil)
    	super("#{element} #{name} ya existe.", 400)
  	end
end
 
class WrongOperationException < AbstractApplicationExcpetion

  def initialize(element, name=nil, opers=[])
      super("Parámetros incorrectos en #{element} #{name}. Operaciones permitidas: #{opers}", 400)
    end
end

class WrongIndexException < AbstractApplicationExcpetion

  def initialize(element, name=nil)
      super("Indice de cubeta incorrecto en #{element} #{name}.", 400)
    end
end