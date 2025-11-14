public class Developer extends Employee {
    private Decimal skillBonus;
    private Integer projectsCompleted;
    private Integer languageCount;
    private Set<String> programmingLanguages; // Stores unique languages

    // Constructor
    public Developer(String fname, String lname, String dept, Decimal salary, Decimal skillBonus, Integer projects, Integer languages) {
        super(fname, lname, dept, salary);

        if (skillBonus == null || skillBonus < 0) {
            throw new IllegalArgumentException('Skill bonus must be non-negative');
        }
        if (projects < 0) {
            throw new IllegalArgumentException('Projects cannot be negative');
        }
        if (languages < 0) {
            throw new IllegalArgumentException('Languages cannot be negative');
        }

        this.skillBonus = skillBonus;
        this.projectsCompleted = projects;
        this.languageCount = languages;
        this.programmingLanguages = new Set<String>();
    }

    // Add a programming language
    public Boolean addProgrammingLanguage(String language) {
        if (String.isBlank(language)) {
            throw new IllegalArgumentException('Language name cannot be blank');
        }

        String properCaseLang = language.substring(0, 1).toUpperCase() + language.substring(1).toLowerCase();

        for (String lang : programmingLanguages) {
            if (lang.equalsIgnoreCase(properCaseLang)) {
                System.debug('Duplicate language detected: ' + properCaseLang);
                return false;
            }
        }

        this.programmingLanguages.add(properCaseLang);
        this.languageCount = this.programmingLanguages.size();
        return true;
    }

    // New Method: Complete a project
    public void completeProject() {
        this.projectsCompleted++;

        // Log project completion with timestamp
        System.debug('Project completed successfully at ' + Datetime.now());

        // Recalculate bonuses automatically through calculateAnnualPay() when needed
    }

    // Override annual pay calculation
    public override Decimal calculateAnnualPay() {
        Decimal totalPay = this.baseSalary;

        Decimal projectBonus = this.projectsCompleted * 1000;
        Decimal languageBonus = this.languageCount * 500;

        Decimal totalBonuses = this.skillBonus + projectBonus + languageBonus;

        // Senior developer bonus if 5+ languages and 10+ projects
        if (this.languageCount >= 5 && this.projectsCompleted >= 10) {
            totalBonuses += this.baseSalary * 0.10;
        }

        // Cap bonuses at 40% of base salary
        Decimal maxAllowedBonus = this.baseSalary * 0.40;
        if (totalBonuses > maxAllowedBonus) {
            System.debug('WARNING: Total bonuses capped at 40% of base salary');
            totalBonuses = maxAllowedBonus;
        }

        totalPay += totalBonuses;
        return totalPay;
    }

    // Getter methods
    public Integer getProjectsCompleted() {
        return this.projectsCompleted;
    }

    public Integer getLanguageCount() {
        return this.languageCount;
    }

    public Decimal getSkillBonus() {
        return this.skillBonus;
    }

    public Set<String> getProgrammingLanguages() {
        return this.programmingLanguages;
    }
}