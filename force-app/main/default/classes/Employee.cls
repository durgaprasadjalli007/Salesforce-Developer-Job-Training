public virtual class Employee {
    public String firstName { get; private set; }
    public String lastName  { get; private set; }
    public String department { get; private set; }
    public Decimal baseSalary { get; private set; }

    // Constructor
    public Employee(String fname, String lname, String dept, Decimal salary) {
        if (String.isBlank(fname)) {
            throw new IllegalArgumentException('First name cannot be blank');
        }
        if (String.isBlank(lname)) {
            throw new IllegalArgumentException('Last name cannot be blank');
        }
        if (String.isBlank(dept)) {
            throw new IllegalArgumentException('Department cannot be blank');
        }
        if (salary == null || salary < 0) {
            throw new IllegalArgumentException('Salary must be positive');
        }

        this.firstName = fname;
        this.lastName = lname;
        this.department = dept;
        this.baseSalary = salary;
    }

    // Default implementation (can be overridden)
    public virtual Decimal calculateAnnualPay() {
        return this.baseSalary;
    }
}