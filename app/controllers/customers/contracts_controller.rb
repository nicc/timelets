class Customers::ContractsController < ApplicationController
  before_filter :load_customer
  
  before_filter :load_contract, :only => [ :show, :edit, :update, :destroy ]
  before_filter :load_contracts, :only => [ :index ]
  before_filter :new_contract, :only => [ :new ]
  before_filter :create_contract, :only => [ :create ]
  before_filter :update_contract, :only => [ :update ]
  before_filter :destroy_contract, :only => [ :destroy ]
  before_filter :load_customers, :only => [ :edit, :new ]
  
  protected
    def load_contract
      @contract = Contract.find(params[:id])
    end

    def new_contract
      @contract = Contract.new  # Yes, I know, it's not a virtual class.  That's probably bad, but it helps here.
    end

    def create_contract
      @contract = contract_subtype(params[:contract_type]).new(params[:contract].merge(:customer_id => @customer.id))
      @created = @contract.save
    end

    def update_contract
      @updated = @contract.update_attributes(params[:contract])
    end

    def destroy_contract
      @contract = @contract.destroy
    end

    def load_contracts
      @contracts = @customer.contracts
    end
    
    def load_customer
      @customer = Customer.find(params[:customer_id], :include => [:contracts])
    end
    
    def load_customers
      @customers = Customer.find(:all, :order => :name)
    end
    
    def contract_subtype(param)
      return case param
        when "RateContract": RateContract
        when "PointContract": PointContract
        else raise "Invalid contract type supplied"
      end
    end
  
  public
    def index
      respond_to do |format|
        format.html
        format.xml  { render :xml => @customers }
        format.js
      end
    end

    def show          
      respond_to do |format|
        format.html
        format.xml  { render :xml => @customer }
        format.js
      end
    end

    def new          
      respond_to do |format|
        format.html { render :action => :edit }
        format.xml  { render :xml => @customer }
        format.js
      end
    end

    def create
      respond_to do |format|
        if @created
          @customer.contracts.reload
          load_contracts # for count
          flash[:notice] = 'Customer was successfully created.'
          format.html { redirect_to @customer }
          format.xml  { render :xml => @customer, :status => :created, :location => @customer }
          format.js
        else
          load_customers # for form
          format.html { render :action => :new }
          format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end 

    def edit
      respond_to do |format|
        format.html
        format.js
      end
    end

    def update
      respond_to do |format|
        if @updated
          @customer.contracts.reload
          load_contracts # for count
          flash[:notice] = 'Customer was successfully updated.'
          format.html { redirect_to @contract }
          format.xml  { head :ok }
          format.js
        else
          load_customers # for form
          format.html { render :action => :edit }
          format.xml  { render :xml => @contract.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end

    def destroy          
      respond_to do |format|
        load_contracts
        format.html { redirect_to :action => customers_url }
        format.xml  { head :ok }
        format.js
      end
    end
end
