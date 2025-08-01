import { LightningElement, api } from 'lwc';
import getPromptDetails from '@salesforce/apex/GenerateAiInsightsController.getPromptDetails';
import updateAISummary from '@salesforce/apex/GenerateAiInsightsController.updateAISummary';

export default class GenerateAiInsights extends LightningElement {
  @api recordId;
  isLoading = false;
  error;

  async handleGenerate() {
    this.isLoading = true;
    this.error = null;

    try {
      const prompt = await getPromptDetails({ evidenceId: this.recordId });

      // Replace this with actual Copilot API call
      const aiResponse = await this.callCopilot(prompt);

      await updateAISummary({ evidenceId: this.recordId, summaryText: aiResponse });
    } catch (err) {
      this.error = err.body?.message || err.message;
    } finally {
      this.isLoading = false;
    }
  }

  async callCopilot(prompt) {
    // Simulated response for now
    return 'This document sufficiently addresses the control requirement by detailing secure transfer methods, encryption protocols, and access controls aligned with the ISO 27001 framework.';
  }
}
