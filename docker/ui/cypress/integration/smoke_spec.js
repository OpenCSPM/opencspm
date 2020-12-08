/// <reference types="Cypress" />

describe('Smoke Test', () => {
  // runs once before all tests in the block
  before(() => {
    cy.clearCookies()
    cy.login()
  })

  // maintain current session through smoke tests
  beforeEach(() => {
    Cypress.Cookies.preserveOnce('_opencspm_session', '_opencspm_token')
  })

  it('can see current campaigns', () => {
    cy.contains('Campaigns').click()
    cy.contains('Campaigns allow you to track the progress of controls you care about.')
    cy.url().should('include', '/campaigns')
  })

  it('can see current profiles and view one', () => {
    cy.contains('Profiles').click()
    cy.url().should('include', '/profiles')
    cy.contains('All Kubernetes').click()
    cy.contains('Send to campaign')
    cy.contains(/^Control \(\d*\)/)
    cy.url().should('include', '/controls')
  })

  it('can see current data sources', () => {
    cy.contains('Sources').click()
    cy.url().should('include', '/sources')
    cy.contains('Inventory Sources')
  })

  it('can see all controls and create a campaign', () => {
    cy.contains('Controls').click()
    cy.url().should('include', '/controls')
    cy.contains(/^Control \(\d*\)/)
    cy.contains('Send to campaign').click()
    cy.contains(/Send \d* controls to campaign+/).click()
    cy.contains('New Campaign')
    cy.url().should('include', '/campaigns')
  })

  it('can see admin details', () => {
    cy.contains('Admin').click()
    cy.url().should('include', '/admin')
    cy.contains('Recent activity')
  })

})
