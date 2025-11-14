public class LoyaltyCustomer {
    public String name;
    public String email;
    public Integer pointsBalance;
    public String membershipLevel;

    public LoyaltyCustomer(String customerName, String customerEmail) {
        if (String.isBlank(customerName)) {
            this.name = 'Unknown Customer';
            System.debug('Warning: Name was empty or null. Setting to default.');
        } else {
            this.name = customerName;
        }

        if (String.isBlank(customerEmail) || !customerEmail.contains('@') || !customerEmail.contains('.')) {
            this.email = 'no-email@example.com';
            System.debug('Warning: Invalid email. Setting to default.');
        } else {
            this.email = customerEmail;
        }

        this.pointsBalance = 0;
        this.membershipLevel = 'Bronze';
    }

    public Boolean addPoints(Integer points) {
        if (points == null || points <= 0) {
            System.debug('Error: Invalid point value. Must be > 0.');
            return false;
        }

        if (points > 100000) {
            System.debug('Error: Excessive points. Transaction denied.');
            return false;
        }

        this.pointsBalance += points;
        System.debug('Added ' + points + ' points to ' + this.name + '. New balance: ' + this.pointsBalance);

        String newLevel = determineMembershipLevel();
        System.debug('Membership level updated to: ' + newLevel);
        return true;
    }

    public Boolean redeemPoints(Integer points) {
        if (points == null || points <= 0) {
            System.debug('Error: Invalid redemption amount. Must be > 0.');
            return false;
        }

        if (points < 100) {
            System.debug('Error: Minimum redemption is 100 points.');
            return false;
        }

        if (points > this.pointsBalance) {
            System.debug('Error: Insufficient points. Current balance: ' + this.pointsBalance);
            return false;
        }

        this.pointsBalance -= points;
        System.debug('Redeemed ' + points + ' points from ' + this.name + '. New balance: ' + this.pointsBalance);

        String newLevel = determineMembershipLevel();
        System.debug('Membership level after redemption: ' + newLevel);
        return true;
    }

    public String determineMembershipLevel() {
        if (this.pointsBalance >= 5000) {
            this.membershipLevel = 'Gold';
        } else if (this.pointsBalance >= 1000) {
            this.membershipLevel = 'Silver';
        } else {
            this.membershipLevel = 'Bronze';
        }
        return this.membershipLevel;
    }

    public String getCustomerSummary() {
        return this.name + ' (' + this.email + ') - ' + this.membershipLevel + ' Member - ' + this.pointsBalance + ' points';
    }

    public Integer getPointsToNextLevel() {
        if (this.pointsBalance >= 5000) {
            return 0;
        } else if (this.pointsBalance >= 1000) {
            return 5000 - this.pointsBalance;
        } else {
            return 1000 - this.pointsBalance;
        }
    }

    public Boolean isEligibleForRedemption(Integer points) {
        if (points == null || points <= 0) return false;
        if (points < 100) return false;
        if (points > this.pointsBalance) return false;
        return true;
    }
}