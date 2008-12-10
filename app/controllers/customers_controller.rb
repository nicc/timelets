class CustomersController < ApplicationController
  before_filter :load_customer, :only => [ :show, :edit, :update, :destroy ]
  before_filter :load_customers, :only => [ :index ]
  before_filter :new_customer, :only => [ :new ]
  before_filter :create_customer, :only => [ :create ]
  before_filter :update_customer, :only => [ :update ]
  before_filter :destroy_customer, :only => [ :destroy ]
  before_filter :load_billing_cycles, :only => [ :edit, :new ]
  
  protected
    def load_customer
      @customer = Customer.find(params[:id])
    end

    def new_customer
      @customer = Customer.new
    end

    def create_customer
      @customer = Customer.new(params[:customer])
      @created = @customer.save
    end

    def update_customer
      @updated = @customer.update_attributes(params[:customer])
    end

    def destroy_customer
      @customer = @customer.destroy
    end

    def load_customers
      @customers = Customer.find(:all)
    end
    
    def load_billing_cycles
      @billing_cycles = BillingCycle.find(:all)
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
          load_customers # for count
          flash[:notice] = 'Customer was successfully created.'
          format.html { redirect_to @customer }
          format.xml  { render :xml => @customer, :status => :created, :location => @customer }
          format.js
        else
          load_billing_cycles
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
          load_customers # for count
          flash[:notice] = 'Customer was successfully updated.'
          format.html { redirect_to @customer }
          format.xml  { head :ok }
          format.js
        else
          load_billing_cycles
          format.html { render :action => :edit }
          format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end

    def destroy          
      respond_to do |format|
        load_customers
        format.html { redirect_to :action => customers_url }
        format.xml  { head :ok }
        format.js
      end
    end
end
