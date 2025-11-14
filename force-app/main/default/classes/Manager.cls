public class Manager extends Employee {
    private List<String> teamMembers;
    private Integer teamSize;
    private Decimal managementBonus;

    // Constructor
    public Manager(String fname, String lname, String dept, Decimal salary, Decimal bonus) {
        super(fname, lname, dept, salary);

        this.teamMembers = new List<String>();
        this.teamSize = 0;

        if (bonus == null || bonus < 0) {
            throw new IllegalArgumentException('Management bonus must be non-negative');
        }

        Decimal maxBonus = salary * 0.5;
        if (bonus > maxBonus) {
            System.debug('WARNING: Bonus exceeds 50% of salary. Capping it to ' + maxBonus);
            this.managementBonus = maxBonus;
        } else {
            this.managementBonus = bonus;
        }
    }

    public void addTeamMember(String empId) {
        if (String.isBlank(empId)) {
            throw new IllegalArgumentException('Employee ID cannot be blank');
        }
        this.teamMembers.add(empId);
        this.teamSize = this.teamMembers.size();
    }

    public List<String> getTeamMembers() {
        return this.teamMembers;
    }

    public Integer getTeamSize() {
        return this.teamSize;
    }

    public Decimal getManagementBonus() {
        return this.managementBonus;
    }
}