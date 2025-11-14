public class SalesRep extends Employee {
    // === Additional Sales-Specific Properties ===
    private Decimal salesTarget;
    private Decimal currentSales;
    private Decimal commissionRate;
    private String territory;
    private List<String> majorClients;

    // === Constructor ===
    public SalesRep(String fname, String lname, Decimal salary, Decimal target, Decimal commRate, String terr) {
        // Call parent constructor (department is always Sales)
        super(fname, lname, 'Sales', salary);

        // === Input Validations ===
        if (target == null || target < 50000 || target > 10000000) {
            throw new IllegalArgumentException('Sales target must be between 50,000 and 10,000,000.');
        }

        if (commRate == null || commRate < 0 || commRate > 20) {
            throw new IllegalArgumentException('Commission rate must be between 0% and 20%.');
        }

        if (String.isBlank(terr)) {
            throw new IllegalArgumentException('Territory cannot be null or empty.');
        }

        // === Initialize SalesRep Properties ===
        this.salesTarget = target;
        this.commissionRate = commRate;
        this.territory = terr;
        this.currentSales = 0;
        this.majorClients = new List<String>();
    }

    // === Overridden Method: calculateAnnualPay() ===
    public override Decimal calculateAnnualPay() {
        Decimal baseSalary = super.calculateAnnualPay();
        Decimal commission = currentSales * (commissionRate / 100);
        Decimal totalPay = baseSalary + commission;

        // === Performance Bonus Logic ===
        if (currentSales >= salesTarget) {
            // 5% extra bonus for hitting 100% target
            totalPay += baseSalary * 0.05;

            // Additional 2% for every 10% over target
            Decimal overAchievementPct = ((currentSales - salesTarget) / salesTarget) * 100;
            if (overAchievementPct > 0) {
                Integer extraSteps = (Integer)(overAchievementPct / 10);
                totalPay += baseSalary * 0.02 * extraSteps;
            }
        }

        // Cap total compensation to avoid absurd numbers
        if (totalPay > (baseSalary * 3)) {
            totalPay = baseSalary * 3;
        }

        return totalPay;
    }

    // === New Method: recordSale() ===
    public Boolean recordSale(Decimal saleAmount, String clientName) {
        // Input validations
        if (saleAmount == null || saleAmount <= 0) {
            throw new IllegalArgumentException('Sale amount must be positive.');
        }
        if (saleAmount > 1000000) {
            throw new IllegalArgumentException('Sale amount cannot exceed 1,000,000.');
        }
        if (String.isBlank(clientName)) {
            throw new IllegalArgumentException('Client name cannot be null or empty.');
        }

        // Update current sales
        currentSales += saleAmount;

        // Track major clients
        if (saleAmount >= 10000 && !majorClients.contains(clientName)) {
            majorClients.add(clientName);
        }

        // Log sale details (using system debug for demo)
        System.debug('Sale recorded: ' + clientName + ' purchased ' + saleAmount + ' at ' + Datetime.now());

        return true;
    }

    // === New Method: getSalesPerformance() ===
    public String getSalesPerformance() {
        Decimal achievementPct = (salesTarget > 0) 
            ? (currentSales / salesTarget) * 100 
            : 0;
        Decimal commissionEarned = currentSales * (commissionRate / 100);

        return 'Sales: $' + currentSales.setScale(2) +
               ' / $' + salesTarget.setScale(2) +
               ' (' + achievementPct.setScale(2) + '%)' +
               ' - Commission: $' + commissionEarned.setScale(2) +
               ' - Major Clients: ' + majorClients.size();
    }
}